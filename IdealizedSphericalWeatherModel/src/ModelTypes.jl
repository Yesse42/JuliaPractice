module ModelTypes

export BaroParams, BaroPreCalc, BaroDims, BaroModVals, BaroModel

using FFTW, QuadGK, GSL

struct BaroParams{T}
    Ω::T
    t0::T
    Δt::T
    ν::T
    rearth::T
    mwnum::Int
    rob::T
end

BaroParams(T=Float64;     
    Ω=T(7.3e-5),
    Δt=T(900.0),
    t0=T(0),
    ν=T(4.0e2),
    rearth=T(6.378e6),
    mwnum=5,
    rob=T(1.0e-3)) = BaroParams(Ω, Δt, t0, ν, rearth, mwnum, rob)

struct BaroDims{T}
    griddims::NTuple{2,Int}
    fourierdims::NTuple{2,Int}
    spectraldims::NTuple{2,Int}
    fourierworkspacedims::NTuple{2,Int}
    weights::Vector{T} # Gaussian Quadrature Weights
    sinlat::Vector{T} #Gauss Quad nodes
    lat::Vector{T} #No need for arcsin after this
    lon::Vector{T} #Nice
    zon::UnitRange{Int} #Zonal Wavenumbers
    tot::UnitRange{Int} #Total Wavenumbers
end

function BaroDims(p::BaroParams{T}) where T
    mwnum = p.mwnum
    gnum = cld(3*mwnum+1,2)
    griddims = (gnum, gnum*2)
    fordims = (gnum, mwnum)
    specdims  = (mwnum+2, mwnum+1) # +1 for 0 wavenmuber, +2 for extra needed mode for meridional derivatives
    workdims = (gnum, gnum+1)
    sinlat, weights = (x->T.(x)).(gauss(gnum))
    lat = T.(asin.(weights))
    lon = T.(range(0, 2π; length=griddims[2]+1))[1:end-1]
    zon = 0:mwnum
    tot = 0:mwnum+1
    return BaroDims(griddims, fordims, specdims, workdims, weights, sinlat, lat, lon, zon, tot)
end

struct BaroPreCalc{T} 
    PLM::Array{T,3} #An array filled with all the PLMs evaluated at every l, m and latitude in use
    ϵTable::Matrix{T} #Quick Meridional Derivatives
    cosθvec::Vector{T} #Useful for vor/div
    FFTPlan::FFTW.rFFTWPlan{T, -1, false, 2, Int} #For that sweet efficiency
    BFFTPlan::FFTW.rFFTWPlan{Complex{T}, 1, false, 2, Int}
end

function BaroPreCalc(d::BaroDims{T}) where T
    plms = zeros(T, d.spectraldims..., d.griddims[1]) #Get the plm for every zonal wav, latitude, and total wav
    for (i, tot) in enumerate(d.tot), (j, zon) in enumerate(0:min(tot,maximum(d.zon))), (k, sinlat) in enumerate(d.sinlat)
        plms[i,j,k]=sf_legendre_sphPlm(tot, zon, sinlat) * sqrt(2π) #Normalization differences
    end
    epsarr = zeros(T, d.spectraldims...)
    for (i, tot) in enumerate(d.tot), (j, zon) in enumerate(0:min(tot,maximum(d.zon)))
        tot==0 && continue
        epsarr[i,j]=((tot^2-zon^2)/4*tot^2-1)
    end
    cosvec = cos.(d.lat)
    fftplan = plan_rfft(d.lat.*(d.lon)', 2)
    bfftplan = plan_brfft(Complex{T}.((1:d.fourierworkspacedims[1]) .* (1:d.fourierworkspacedims[2])'), d.griddims[2], 2)
    BaroPreCalc(plms, epsarr, cosvec, fftplan, bfftplan)
end

mutable struct BaroModVals{T}
    time::T
    griducos::Matrix{T}
    specucos::Array{Complex{T},2}
    gridvcos::Array{T,2}
    specvcos::Array{Complex{T},2}
    gridstream::Array{T,2}
    specstream::Array{Complex{T},2}
end

function BaroModVals(d::BaroDims{T}; time=0) where T
    time=T(time)
    griducos = zeros(T, d.griddims...)
    specucos = zeros(Complex{T}, d.spectraldims...)
    gridvcos = zeros(T, d.griddims...)
    specvcos = zeros(Complex{T}, d.spectraldims...)
    gridstream = zeros(T, d.griddims...)
    specstream = zeros(Complex{T}, d.spectraldims...)
    BaroModVals(time, griducos, specucos, gridvcos, specvcos, gridstream, specstream)
end

const n_workspaces=3
"For calculating temporaries without excessive allocation"
struct BaroWorkSpace{T}
    four::NTuple{n_workspaces, Matrix{Complex{T}}}
    spec::NTuple{n_workspaces, Matrix{Complex{T}}}
    grid::NTuple{n_workspaces, Matrix{T}}
end

function BaroWorkSpace(d::BaroDims{T}) where T
    four = Tuple(zeros(Complex{T}, d.fourierworkspacedims...) for _ in 1:n_workspaces)
    spec = Tuple(zeros(Complex{T}, d.spectraldims...) for _ in 1:n_workspaces)
    grid = Tuple(zeros(T, d.griddims...) for _ in 1:n_workspaces)
    BaroWorkSpace(four, spec, grid)
end

struct BaroModel{T}
    params::BaroParams{T}
    dims::BaroDims{T}
    pcalc::BaroPreCalc{T}
    old::BaroModVals{T}
    now::BaroModVals{T}
    new::BaroModVals{T}
    workspace::BaroWorkSpace{T}
end

function BaroModel(params::BaroParams)
    dims=BaroDims(params)
    pcalc=BaroPreCalc(dims)
    old, now, new = ntuple(i->BaroModVals(dims;time=params.t0+params.Δt*(i-2)),Val(3))
    workspace=BaroWorkSpace(dims)
    return BaroModel(params, dims, pcalc, old, now, new, workspace)
end

end
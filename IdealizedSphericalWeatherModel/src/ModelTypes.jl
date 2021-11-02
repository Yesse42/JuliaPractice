module ModelTypes

export BaroParams, BaroPreCalc, BaroDims, BaroModVals

using FFTW, QuadGK, GSL

struct BaroParams{T}
    Ω::T
    Δt::T
    ν::T
    rearth::T
    mwnum::N
    rob::T
end

BaroParams(T=Float64;     
    Ω=T(7.3e-5),
    Δt=T(900.0),
    ν=T(4.0e2),
    rearth=T(6.378e6),
    mwnum=T(5),
    rob=T(1.0e-3)) = BaroParams(Ω, Δt, ν, rearth, mwnum, rob)

struct BaroDims{T} 
    griddims::NTuple{2,T}
    fourierdims::NTuple{2,T}
    spectraldims::NTuple{2,T}
    fourierworkspacedims::NTuple{2,T}
    weights::Array{T,1} # Gaussian Quadrature Weights
    sinlat::Array{T,1} #Gauss Quad nodes
    lat::Array{T,1} #No need for arcsin after this
    lon::Array{T,1} #Nice
    zon::UnitRange{Int} #Zonal Wavenumbers
    tot::UnitRange{Int} #Total Wavenumbers
end

function BaroDims(p::BaroParams{T}) where T
    gnum = cld(3*p.mwnum+1,2)
    griddims = (gnum, gnum*2)
    fordims = (gnum, mwnum)
    specdims  = (mwnum+2, mwnum+1) # +1 for 0 wavenmuber, +2 for extra needed mode for meridional derivatives
    workdims = (gnum, gnum+1)
    sinlat, weights = (x->T.(x)).(gauss(griddims[1]))
    lat = T.(asin.(weights))
    lon = T.(range(0, 2π; length=griddims[2]+1))[1:end-1]
    zon = 0:mwnum
    tot = 0:mwnum+1
    return BaroDims(griddims, fordims, specdims, workdims, weights, sinlat, lat, lon, zon, tot)
end

struct BaroPreCalc{T} 
    PLM::Array{T,3} #An array filled with all the PLMs evaluated at every l, m and latitude in use
    ϵTable::Array{T,2} #Quick Meridional Derivatives
    cosθvec::Array{T,1} #Useful for vor/div
    FFTPlan::FFTW.rFFTWPlan{T, -1, false, 2, Int} #For that sweet efficiency
end

function BaroPreCalc(d::BaroDims{T}) where T
    plms = zeros(T, d.specdims..., d.griddims[1]) #Get the plm for every total wav, zonal wav, and latitude
    for (i, tot) in enumerate(d.tot), (j, zon) in enumerate(0:tot), (k, sinlat) in enumerate(d.sinlat)
        plms[i,j,k]=sf_legendre_sphPlm(tot, zon, sinlat)
    end
    epsarr = zeros(T, d.specdims...)
    for (i, tot) in enumerate(d.tot), (j, zon) in enumerate(0:tot)
        tot==0 && continue
        epsarr[i,j]=((tot^2-zon^2)/4*tot^2-1)
    end
    cosvec = cos.(lat)
    fftplan = plan_rfft(d.lat.*(d.lon)', 2)
    BaroPreCalc(plms, epsarr, cosvec, fftplan)
end

struct BaroModVals{T}
    time::T
    griducos::Array{T,2}
    specucos::Array{Complex{T},2}
    gridvcos::Array{T,2}
    specvcos::Array{Complex{T},2}
    gridvort::Array{T,2}
    specvort::Array{Complex{T},2}
    vorttend::Array{Complex{T},2}
end

function BaroModVals(d::BaroDims{T}; time=0) where T
    time=T(time)
    griducos = zeros(T, d.griddims...)
    specucos = zeros(T, d.spectraldims...)
    gridvcos = zeros(T, d.griddims...)
    specvcos = zeros(T, d.spectraldims...)
    gridvort = zeros(T, d.griddms...)
    specvort = zeros(T, d.spectraldims...)
    vorttend = zeros(T, d.spectraldims...)
    BaroModVals(time, griducos, specucos, gridvcos, specvcos, gridvort, specvort, vorttend)
end

struct BaroWorkSpace{T}
    fourierworkspace::Array{Complex{T}, 2}
end

function BaroWorkSpace(d::BaroDims::T)
    BaroWorkSpace(zeros(T, d.fourierworkspacedims...))
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

end
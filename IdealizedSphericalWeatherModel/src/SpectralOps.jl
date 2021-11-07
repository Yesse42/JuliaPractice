module SpectralOps

export gridtofourier!, fouriertospec!, spectofourier!, fouriertogrid!, specvor!, specdiv!

using FFTW, LinearAlgebra

#Notes: the PLM Array is indexed by zonw, totw, and then sinlat
#The spectral array is indexed by totw and then zonw
#The actual grid is indexed by sinlat and lon
#The fourier grid is indexed by sinlat and zonw, with zonw going above maxwavenum to 2*maxwavenum+1

function spectofourier!(outfourier, inspec; plmarr, sinlats, zonws)
    #Set the higher modes to 0
    outfourier[:, length(zonws)+1:end] .= 0
    #And get the spectral values into the workarr using the inverse legendre transform (essentially an inner product).
    for i in eachindex(sinlats), j in eachindex(zonws)
        @views outfourier[i,j] = plmarr[:,j, i] ⋅ inspec[:, j]
    end
end

function fouriertogrid!(outgrid, fouriervals; forwardplan)
    #Transform the fourier values to the grid
    ldiv!(outgrid, forwardplan, fouriervals)
end

function gridtofourier!(outfourier, ingrid; forwardplan, zonws)
    #Get the fourier values
    mul!(outfourier, forwardplan, ingrid)
    #Set the higher wavenumbers to 0
    outfourier[:,length(zonws)+1:end] .= 0
end

function fouriertospec!(outspec, infourier; weights, totws, zonws, sinlats, plmarr)
    for i in eachindex(totws), j in eachindex(zonws)
        @views outspec[i,j] = weights ⋅ (infourier[latidx,i] * plmarr[j,i,latidx] for latidx in eachindex(sinlats))
    end
end

end
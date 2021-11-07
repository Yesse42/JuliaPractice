module SpectralOps

export gridtofourier!, fouriertospec!, spectofourier!, fouriertogrid!, specvor!, specdiv!

using FFTW, LinearAlgebra
import Base.Iterators as Itr

#Notes: the PLM Array is indexed by totw, zonw, and then lat
#The spectral array is indexed by totw and then zonw
#The actual grid is indexed by sinlat and lon
#The fourier grid is indexed by sinlat and zonw, with zonw going above maxwavenum to 2*maxwavenum+1

function spectofourier!(outfourier, inspec; plmarr, sinlats, zonws, totws)
    #Set the higher modes to 0
    outfourier[:, length(zonws)+1:end] .= 0
    #And get the spectral values into the workarr using the inverse legendre transform.
    for i in eachindex(sinlats), (j,zonw) in enumerate(zonws)
        valid_wavenums=j:length(totws)
        @views outfourier[i,j] = plmarr[valid_wavenums,j, i] ⋅ inspec[valid_wavenums, j]
    end
end

function fouriertogrid!(outgrid, fouriervals; backplan)
    #Transform the fourier values to the grid
    mul!(outgrid, backplan, fouriervals)
end

function gridtofourier!(outfourier, ingrid; forwardplan, zonws)
    #Get the fourier values
    mul!(outfourier, forwardplan, ingrid)
    #Set the higher wavenumbers to 0
    outfourier[:,length(zonws)+1:end] .= 0
    #Divide the rest by the length
    outfourier[:, 1:length(zonws)] ./= 2*(size(outfourier, 2)-1)
end

function fouriertospec!(outspec, infourier; weights, totws, zonws, plmarr)
    for (i, totw) in enumerate(totws), (j,zonw) in enumerate(0:min(totw, maximum(zonws)))
        @views outspec[i,j] = weights ⋅ Itr.map(*, infourier[:,j], plmarr[i,j,:])
    end
end

function speczonalderiv()

end

function specmerideriv( ;epstable)

end

"The G operator, operating on spectral coefficient arrays A and B. Assumes a triangular truncation, 
and that there is 1 extra total wavenumber compared to zonal wavenumber for meridional derivatives"
function 𝓖!(out, A, B; zonw, totw)

end

function specvorfromuv!()

end

function specdivfromuv!()

end

end
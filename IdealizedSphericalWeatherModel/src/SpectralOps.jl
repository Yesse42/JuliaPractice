module SpectralOps

export gridtofourier!, fouriertospec!, spectofourier!, fouriertogrid!, spectogrid!, 𝓖!, cos2specmerideriv!, speczonalderiv!, spectrallaplacian!, invspectrallaplacian!

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

function gridtofourier!(outfourier, ingrid; backplan, zonws)
    #Get the fourier values by applying the backwards transform
    ldiv!(outfourier, backplan, ingrid)
    #Set the higher wavenumbers to 0
    outfourier[:,length(zonws)+1:end] .= 0
end

function fouriertospec!(outspec, infourier; weights, totws, zonws, plmarr)
    for (i, totw) in enumerate(totws), (j,zonw) in enumerate(0:min(totw, maximum(zonws)))
        @views outspec[i,j] = weights ⋅ Itr.map(*, infourier[:,j], plmarr[i,j,:])
    end
end

function speczonalderiv!(outspec, inspec; zonws)
    for (i, zonw) in enumerate(zonws)
        outspec[:,i] .= im .* zonw .* inspec[:,i]
    end
end

function spectogrid!(outgrid, fourierworkspace, inspec; backplan, plmarr, sinlats, zonws, totws)
    spectofourier!(fourierworkspace, inspec; plmarr=plmarr, sinlats=sinlats, zonws=zonws, totws=totws)
    fouriertogrid!(outgrid, fourierworkspace; backplan=backplan)
end

function cos2specmerideriv!(outspec, inspec; epstable, totws, zonws)
    for (i, totw) in enumerate(totws), (j, zonw) in enumerate(0:min(totw,maximum(zonws)))
        #Don't use the final totw mode, as it doesn't have the extra mode for the derivative
        i==length(totws) && break
        if totw == zonw
            outspec[i,j] = (totw+2)*epstable[i+1,j]*inspec[i+1,j]
        else
        outspec[i,j] = -(totw-1)*epstable[i,j]*inspec[i-1, j]+
                        (totw+2)*epstable[i+1,j]*inspec[i+1,j]
        end
    end
end

function spectrallaplacian!(outspec, inspec, rearth; totws)
    for (i, totw) in enumerate(totws)
        outspec[i,:] .*= totw*(totw+1)/rearth^2 .* inspec[i,:]
    end
end

function invspectrallaplacian!(inoutspec, rearth; totws)
    for (i, totw) in enumerate(totws)
        if totw == 0
            inoutspec[i,:] .= 0
            continue
        end
        inoutspec[i,:] .*= rearth^2/(totw*(totw+1))
    end
end

function cos2dplm(latidx, l,lidx, m, midx, plmarr, epstable)
    if l==m
        -l*epstable[lidx+1,midx]*plmarr[lidx+1,midx, latidx]
    else
        (l+1)*epstable[lidx,midx]*plmarr[lidx-1,midx,latidx] -
        l*epstable[lidx+1,midx]*plmarr[lidx+1,midx, latidx]
    end
end

"An intermediate function in the calculation of 𝓖"
function muldiff(r, s, cosθ, latidx, plmarr, epstable, l, m, lidx, midx)
    1/(cosθ^2) * (im*r*plmarr[lidx,midx,latidx] - s*cos2dplm(latidx, l, lidx, m, midx, plmarr, epstable))
end

"The G operator, operating on fourier arrays R and S and returning spectral coefficients in outspec. Assumes a triangular truncation, 
and that there is 1 extra total wavenumber compared to zonal wavenumber for meridional derivatives"
function 𝓖!(outspec, R, S; zonws, totws, rearth, weights, plmarr, epstable, cosvec, latidxs)
    for (i, totw) in enumerate(totws), (j, zonw) in enumerate(0:min(maximum(zonws),totw))
        curryfunc(r, s, cosθ, latidx) = muldiff(r, s, cosθ, latidx, plmarr, epstable, totw, zonw, i, j)
        @views outspec[i,j] = 1/rearth * (weights ⋅ Itr.map(curryfunc, R[:,j], S[:, j], cosvec, latidxs))
    end
end

end
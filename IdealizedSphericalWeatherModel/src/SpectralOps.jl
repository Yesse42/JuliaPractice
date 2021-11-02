module SpectralOps

export gridtofourier!, fouriertospec!, spectofourier!, fouriertogrid!, specvor!, specdiv!

using FFTW, LinearAlgebra

function spectofourier!(outfourier, specvals; plmarr, sinlats, zonws)
    #First get the intermediate fourier values into the workarr
    for (i, _) in enumerate(sinlats), (j, _) in enumerate(zonws)
        @views outfourier[i,j] = plmarr[:,j, i] ⋅ specvals[:, j]
    end
end

function fouriertogrid!(outgrid, fouriervals; plmarr, sinlats, zonws)
    #First get the intermediate fourier values into the workarr
    for (i, _) in enumerate(sinlats)
        @views outfourier[i,j] = plmarr[:,j, i] ⋅ specvals[:, zonw]
    end
end

end
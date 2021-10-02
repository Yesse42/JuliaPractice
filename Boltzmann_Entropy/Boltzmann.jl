using UnicodePlots, StatsBase

function wraptovalididx(i::Integer,min,max)
    return abs((i-min)%max)+min
end

function wraptovalidcartidx(indidx::CartesianIndex,mins,maxes)
    return CartesianIndex((wraptovalididx(i,mini,maxi) for (i,mini,maxi) in zip(Tuple(indidx),Tuple(mins),Tuple(maxes)))...)
end

function wraptovalid(x::CartesianIndices{N},minidx::CartesianIndex{N},maxidx) where N
    return map((y->wraptovalidcartidx(y,minidx,maxidx)),x)
end

"Moves energy particles around from A into B"
function move_energy!(A,B)
    B.=0
    R=CartesianIndices(A)
    firstidx, lastidx = first(R), last(R)
    one = oneunit(typeof(firstidx))
    for I in R
        n_energy=A[I]
        for j in 1:n_energy
            idx_adjacent=(I-one):(I+one)
            idx_valid=wraptovalid(idx_adjacent,firstidx,lastidx)
            new_idx=rand(idx_valid)
            B[new_idx]+=1
        end
    end
end

function main(start_energy,dims,n_iter)
    A=fill(start_energy,dims)
    B=zeros(Int64,size(A))
    if n_iter%2 == 1
        B.=A
        move_energy!(B,A)
    end
    for i in 1:fld(n_iter,2)
        move_energy!(A,B)
        move_energy!(B,A)
    end
    display(sum(A))
    return A
end

using StatsBase

out=main(2,(100,100),200)

hist=fit(Histogram, out[:], 0:75)

using Plots
gr()
plot(hist.edges[1][1:end-1],hist.weights)
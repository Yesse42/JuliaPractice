function main(start_energy::T,quantum::T,dims,n_iter) where {T<:Number}
    start_energy < quantum && throw(DomainError((energy=start_energy,quantum=quantum),"WHAAAAAT!!! How is energy less than Quantum"))
    A=fill(start_energy,dims)
    inds=collect(eachindex(A))
    for i in 1:n_iter
        randputind=randtakeind=0
        while true
            randtakeind=rand(inds)
            A[randtakeind] ≠ 0 && break
        end
        randputind=rand(inds)
        A[randtakeind]-=quantum
        A[randputind]+=quantum
    end
    return A
end

using StatsBase

energy=100

quantum=1

out=main(energy,quantum,Int.((1e1,1e1,1e1)),1e10)

hist=fit(Histogram, out[:], range(0,20*energy;step=quantum))

hist=StatsBase.normalize(hist;mode=:pdf)

using Plots
gr()
dom=hist.edges[1][1:end-1]
plot(dom,hist.weights)


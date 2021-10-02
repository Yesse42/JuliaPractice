include("p10.jl")

triang(n)=n*(n+1) ÷ 2

#Get the primes up to 1000
const primevec=sieve_of_erastothenes(5000)

function prime_factorize(n,primes)
    out=zeros(size(primes))
    for i in eachindex(primes)
        count=0
        while(n % primes[i]^(count+1) == 0)
            count+=1
        end
        out[i]=count
    end
    return out
end

function composite_triangs()
    nprimes=Array{Int}(undef, length(primevec))
    n1primes=Array{Int}(undef, length(primevec))
    total_factors=Array{Int}(undef, length(primevec))
    n=0
    nfactors=0
    while(nfactors<=500)
        n+=1
        nprimes.=prime_factorize(n,primevec)
        n1primes.=prime_factorize(n+1,primevec)
        #Get the total number of factors, account for the division by 2. .+1 accounts for not taking a factor to be a valid permutations
        total_factors.=nprimes.+n1primes.+1
        total_factors[1]-=1
        nfactors=prod(total_factors)
    end
    return triang(n)
end

display(composite_triangs())
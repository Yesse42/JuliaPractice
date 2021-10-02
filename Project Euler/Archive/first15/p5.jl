include("p4.jl")

const top=20

const primes=[2,3,5,7,11,13]

function prime_factorize(n)
    out=zeros(size(primes))
    for i in eachindex(primes)
        count=0
        while(n % primes[i]^count == 0)
            count+=1
        end
        out[i]=count
    end
    return out
end

function smallest_mult()
    mynum=1
    for num in 2:top
        myfactors=prime_factorize(mynum)
        numfactors=prime_factorize(num)
        g0(x::T) where T=if x<0 return T(0) else return x end
        needed_factors=g0.(numfactors.-myfactors)
        g1(x::T) where T<:Number=if x<1 return T(1) else return x end
        display((mynum,num))
        display((myfactors,numfactors,needed_factors,prod(g1.(needed_factors.*primes))))
        mynum*=prod(g1.(needed_factors.*primes))
    end
    return mynum
end

result=smallest_mult()

display(result)

test= result ./ collect(2:top)

display(test)

trunc.(Int, test) .== test
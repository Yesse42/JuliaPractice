function next_prime(primes)
    current_num=primes[end]+2
    if iseven(current_num)
        current_num-=1
    end
    while(true)
        if all(rem.(current_num,primes) .≠ 0)
            return current_num
        end
        current_num+=2
    end
end

function get_primes(max::T) where T
    pvec=Array{T}(undef,1)
    pvec[1]=2
    while pvec[end]<max
        push!(pvec,next_prime(pvec))
    end
    return pvec
end

vec=get_primes(Int(2e6))

display(sum(vec))
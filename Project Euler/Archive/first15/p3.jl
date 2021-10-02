const magicnum=600851475143

"Assumes prime list is sorted"
function next_prime(primes)
    if isempty(primes) return 2 end
    current_num=primes[end]+1
    while(true)
        if all(rem.(current_num,primes) .≠ 0)
            return current_num
        end
        current_num+=1
    end
end

function larget_prime_factor()
    #First search for primes up to root n, and then divide the magnicnum by all the primes it has in it
    primes=Int[]
    pcount=Int[]
    num=magicnum
    while num>1
        newprime=next_prime(primes)
        push!(primes,newprime)
        divi, rema= divrem(num,newprime)
        if rema==0
            push!(pcount,divi)
            num ÷= (divi*newprime)
        else 
            push!(pcount,0)
        end
    end
    display(sum(pcount.*primes))
    return primes[end]
end

larget_prime_factor()
function sieve_of_erastothenes(size)
    #Start at 2 so we can
    primes=Int[2]
    mask=trues(size)
    i=3
    while(i<=size)
        #If the place has not been sieved out
        if mask[i]
            #Mask it out, and all places divisible by it
            @views mask[i:i:size].=false
            #Record the number as prime
            push!(primes,i)
        end
        i+=2
    end
    return primes
end

# primes=sieve_of_erastothenes(Int(2e6))

# display(primes)

# display(sum(primes))
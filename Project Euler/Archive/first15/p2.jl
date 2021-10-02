function even_fib_sum()
    cache=Dict{Int,Int}(1=>1,2=>2)
    function recursive_fib(n)
        if haskey(cache,n)
            return cache[n]
        else
            return cache[n]=recursive_fib(n-1)+recursive_fib(n-2)
        end
    end
    sum=0
    i=1
    while(recursive_fib(i)<4e6)
        fib=recursive_fib(i)
        iseven(fib) && (sum+=fib)
        i+=1
    end
    display(sum)
end

even_fib_sum()
            


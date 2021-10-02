module GCD

export gcd

"I think my issues were more theoretical than practical"
function gcd(a,b; verbose=true)
    while b ≠ 0
        verbose && println((a,b))
        a, b = b, a%b
    end
    verbose && println((a,b))
    a
end

end # module

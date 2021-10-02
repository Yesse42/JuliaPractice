const n=1000

function trips()
    for a in 1:cld(1000,3)
        for b in a+1:cld(n-a,2)
            c=n-a-b
            if a^2+b^2==c^2
                return prod((a,b,c))
            end
        end
    end
end

trips()
function find_palindrome()
    for i ∈ 999:-1:100
        for j ∈ 999:-1:i
            pali=string(i*j)
            if @views pali[1:cld(end,2)]==reverse(pali[cld(end,2):end])
                return pali
            end
        end
    end
end

find_palindrome()
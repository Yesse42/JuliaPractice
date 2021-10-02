using Memoize

@memoize function collatz_chain_length(input::Int)::Int
    if input==1
        return 1
    elseif iseven(input)
        return 1 + collatz_chain_length(input ÷ 2)
    else
        return 1 + collatz_chain_length(3input + 1)
    end
end

function longest_chain(numbers)
    num_of_streak=0
    longest_chain=0
    for num in numbers
        len=collatz_chain_length(num)
        if len>longest_chain
            longest_chain=len
            num_of_streak=num
        end
    end
    return num_of_streak
end

display(longest_chain(1:10^6))
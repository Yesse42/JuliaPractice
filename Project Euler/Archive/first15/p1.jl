function sum3_5(n)
    return sum(3:3:n)+sum(5:5:n)-sum(15:15:n)
end

display(sum3_5(1000))
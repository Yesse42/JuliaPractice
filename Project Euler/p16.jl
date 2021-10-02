function pow_dig_sum()
    sr=string(big(2)^1000)
    return sum(parse(Int,char) for char in sr)
end

pow_dig_sum()

function pow_dig_sum()
    max_dig=trunc(Int,1000log10(2))
    digitarr=zeros(Int64,max_dig)
    for i in 1:max_dig
end
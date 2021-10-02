using Memoize

const digichars=Tuple(num for num in 0:9)

function sum_near_squares(digits)
    #The numbers are read left to right for some reason because that's how evalpoly works
    numbers=Iterators.product((digichars for i in 1:digits)...)
    accum=0
    count=0
    for num in numbers
        actual_num=evalpoly(10,num)
        k=1
        digisum=0
        while(digisum<actual_num+2)
            count+=1
            digisum=sum(num.^k)
            if digisum==actual_num+1 || digisum==actual_num-1
                accum+=actual_num
            end
            k+=1
            if all(num.<=1) break end
        end
    end
    display(count)
    return accum
end

function sum_near_squares_less(digits)
    if digits==0
        return 0
    else
        return sum_near_squares(digits)+sum_near_squares_less(digits-1)
    end
end

sum_near_squares_less(6)
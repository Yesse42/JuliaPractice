module EvalFuncs

export mse, mae, gini_impurity, entropy

using Dictionaries, Statistics

function count_occurences(itr)
    elements=Dictionary{eltype(itr), Int}()
    for el in itr
        if haskey(elements, el)
            elements[el]+=1
        else
            insert!(elements, el, 1)
        end
    end
end

function error(itr, errorfunc)
    avg = mean(itr)
    return sum(errorfunc(el-mean) for el in itr)
end

mse(itr)=error(itr, x->x^2)
mae(itr)=error(itr, abs)

function gini_impurity(itr)
    elcounts=count_occurences(itr)
    len=length(itr)
    return len - sum(el^2 for el in elcounts)/len^2
end

function entropy(itr)
    elcounts=count_occurences(itr)
    len=length(iter)
    return sum(begin
        prob = count/len
        -prob*log2(prob)
    end for count in elcounts)
end

end
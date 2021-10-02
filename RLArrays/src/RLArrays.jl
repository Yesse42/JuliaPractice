module RLArrays
export RunLengthArray

struct RunLengthArray{T,N} <: AbstractArray{T,N}
    elements::Vector{T}
    runstarts::Vector{Int}
    size::Ref{NTuple{N, Int}}
end

function RunLengthArray(A; compfunc = isequal)
    N = length(size(A))
    T = eltype(A)
    numchanges = 0
    prevelement = first(A)


    elements=T[first(A)]
    runstarts=Int[1]

    prevelement = first(elements)
    rlarray_idx = 2
    for (i, element) in enumerate(A)
        i==1 && continue
        if !compfunc(element, prevelement)
            push!(elements, element)
            push!(runstarts, i)

            prevelement = element
            rlarray_idx += 1
        end
    end
    return RunLengthArray(elements, runstarts, Ref(size(A)))
end

"Uses binary search to return the index of the closest value which is less than the given num"
function binsearch(num, itr; lt=isless)
    lower, upper = extrema(eachindex(itr))
    if !lt(num, itr[upper]) return upper end
    while upper-lower>1
        mid=fld(lower+upper, 2)
        if lt(num, itr[mid])
            upper=mid
        else
            lower=mid
        end
    end
    return lower
end

Base.IndexStyle(::RunLengthArray) = Base.IndexLinear()

Base.size(A::RunLengthArray) = A.size[]

function Base.getindex(A::RunLengthArray, i::Int)
    element_index = binsearch(i, A.runstarts)
    return A.elements[element_index]
end

function Base.setindex!(A::RunLengthArray, v, i::Int)
    element_index = binsearch(i, A.runstarts)
    #Check if the value of a preexisting run is being changed
    if i == A.runstarts[element_index]
        A.elements[element_index] = v

    #Insert a new run with a new value at the index
    else
        insert!(A.elements, element_index+1, v)
        insert!(A.runstarts, element_index+1, i)
    end
end

end # module

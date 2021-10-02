module StructIterator

import Base: iterate, eltype, IteratorSize, IteratorEltype, length

export structiter

struct StructIter{T}
    eltuple::T
end

@generated function structiter(strct::T) where T
    fields=fieldnames(T)
    myargs=(:(strct.$(name)) for name in fields)
    quote
        StructIter(tuple($(myargs...)))
    end
end

for op in Symbol.((iterate, eltype, IteratorSize, IteratorEltype, length))
    @eval $op(itr::StructIter{T}) where T=$op(itr.eltuple)
end

iterate(itr::StructIter{T}, state) where T=iterate(itr.eltuple, state)

end # module

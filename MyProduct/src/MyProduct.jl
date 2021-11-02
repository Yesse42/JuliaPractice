module MyProduct

import Base: iterate, setindex, IteratorSize, IteratorEltype, length, size, eltype
import Base: HasEltype, HasShape, EltypeUnknown, SizeUnknown, IsInfinite
import Base.Iterators as Itr

export MyProd

struct MyProd{T<:Tuple}
    iters::T
    function MyProd(iters...)
        length(iters) < 1 
        new{typeof(iters)}(iters)
    end
end

IteratorEltype(x::MyProd{T}) where T = if all(IteratorEltype.(x.iters).≡HasEltype()) HasEltype() else EltypeUnknown() end
function IteratorSize(x::MyProd{T}) where T 
    if any(Itr.map(x->x isa IsInfinite, IteratorSize.(x.iters)))
        IsInfinite() 
    elseif any(Itr.map(x->x isa SizeUnknown, IteratorSize.(x.iters)))
        SizeUnknown() 
    else 
        HasShape{length(x.iters)}() 
    end
end

size(x::MyProd)= length.(x.iters)
size(x::MyProd, dim::Integer) = length(x.iters[dim])
length(x::MyProd) = prod(size(x))
eltype(x::MyProd) = Tuple{eltype.(x.iters)...}

function iterate(piter::MyProd{T}) where T 
    iterstates = map(Base.iterate, piter.iters)
    any(map(isnothing, iterstates)) && return nothing
    return (map(x->x[1], iterstates),iterstates)
end

function iterate(piter::MyProd{T}, state) where T
    iters=piter.iters
    piterate(iters, state)
end

"The piterator state object contains both the previous value and state returned by that iterator"
function piterate(iters, states)
    val, state = nothing, nothing
    next_iter = iterate(iters[1], states[1][2]) #states[1][2] is taking the state of the first iterator
    if next_iter ≡ nothing
        length(iters)==1 && return nothing
        valstates_rest=piterate(iters[2:end], states[2:end])
        valstates_rest ≡ nothing && return nothing
        freshstate=iterate(iters[1])
        val=tuple(freshstate[1], valstates_rest[1]...)
        state=tuple(freshstate, valstates_rest[2]...)
    else
        val=tuple(next_iter[1], getindex.(states[2:end], 1)...)
        state=tuple(next_iter, states[2:end]...)
    end
    return (val, state)
end

end # module

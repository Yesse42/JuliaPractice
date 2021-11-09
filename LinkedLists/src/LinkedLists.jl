module LinkedLists

export LinkedList

import Base: setindex!, getindex, size, iterate, length, insert!, delete!

mutable struct LinkedList{T} <: AbstractArray{T,1}
    data::T
    next::Union{LinkedList{T},Nothing}
end

function _linked_list(itr)
    el=iterate(itr)
    if isnothing(el)
        return nothing
    else
        return LinkedList(el[1], _linked_list(itr))
    end
end

function LinkedList(itr)
    itr=Iterators.Stateful(itr)
    LinkedList(first(itr), _linked_list(itr))
end

function length(list::LinkedList)
    len=1
    while list.next ≢ nothing
        len+=1
        list=list.next
    end
    return len
end

size(x::LinkedList)=(length(x),)

function getindex(x::LinkedList, i::Integer)
    while i>1
        x=x.next
        i-=1
    end
    return x.data
end

function setindex!(x::LinkedList,v, i::Integer)
    while i>1
        x=x.next
        i-=1
    end
    x.data = v
end

function insert!(x::LinkedList, v, i::Integer)
    original = x
    while i>2
        x=x.next
        i-=1
    end
    newnext = x.next
    x.next = LinkedList(v, newnext)
    return original
end

function delete!(x::LinkedList, i::Integer)
    original = x
    while i>2
        x=x.next
        i-=1
    end
    delnode=x.next
    newnext = delnode.next
    x.next = newnext
    return original
end

end # module

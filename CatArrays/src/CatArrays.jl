module CatArrays

export cat, CatArray

import Base.setindex

function extend_index(index::Tuple, N::Integer)
    len=length(index)
    return ntuple(i -> if i>len return Base.OneTo(1) else return index[i] end, N)
end

"Checks if all the indices are compatible for concatenation. Assumes extend_index has already been called"
function checkinds(inds, dim)
    length(inds)==1 && return true
    tup1=first(inds)
    for ind in inds[2:end]
        for i in eachindex(ind)
            i==dim && continue
            collect(ind[i])==collect(tup1[i]) || return false
        end
    end
    return true
end

getdim(A::AbstractArray{T,N}) where {T,N}=N

"Lazily Concatenates your arrays together on dim, which must be a Val type.
The indices of all arrays you seek to concatenate must be equal (except on the concatenation dimension)
Uses binary search of indbounds in getindex for SPEEED
Suffers from excessive parametrization.
Also note that when concatenating more than about 10 arrays together the compiler gives up on type inference of indbounds and so instability is inevitable"
struct CatArray{CatDim, T, N, Arrs, Nless1, CatLen} <: AbstractArray{T,N} where {Arrs<:Tuple}
    arrays::Arrs
    catdim_indices::NTuple{CatLen, UnitRange{Int}}
    other_indices::NTuple{Nless1, UnitRange{Int}}
    indbounds::NTuple{CatLen, Int}
    size::NTuple{N, Int}
    "You must pass all keyword arguments as value types (e.g. Val(1)). When the value type is a constant literal, it allows for proper type inference. 
    When it isn't a constant literal, there would be type instability anyways, so just still wrap it in Val"
    function CatArray(arrays::AbstractArray...; dim::Val{dim_lit}, uniontype::Val{uniontype_lit}=Val(true)) where {dim_lit, uniontype_lit}
        isempty(arrays) && throw(ArgumentError("You haven't provided any arrays"))
        my_eltype = if uniontype_lit Union{eltype.(arrays)...} else Base.promote_eltype(arrays) end
        indices = axes.(arrays)
    
        #Get the dimensions of the CatArray
        N = max(maximum(getdim.(arrays)), dim_lit)

        catlen=length(arrays)
    
        #Now extend the indices out to a common dimension N
        exinds=extend_index.(indices, N)
    
        #Check if the indices can be concatenated together
        checkinds(exinds, dim_lit) || throw(ArgumentError("The dimensions of the arrays you supplied cannot be concatenated together"))
    
        #Now join the indices of the concatenated dimension into a single monstrous tuple
        catmonster = getindex.(exinds, dim_lit)
    
        #Take the first index tuple of the arrays (already checked to all be equal in size), but remove the dim index
        otherind = exinds[1][(1:N).≠dim_lit]
        
        #Now get the indices at which the catindex changes the array it is indexing into. This torturous function usage is for type stability, because slicing tuples is not stable.
        function indcalcfunc(monsteridx)
            if monsteridx==1 
                1 
            else 
                sum(length(catmonster[i]) for i in 1:(monsteridx-1))+1
            end
        end
        indbounds=ntuple(i->indcalcfunc(i), length(catmonster))

        #Now lastly precalculate the sizes. When it wasn't precalculated there were a lot of allocations
        mysizes=ntuple(i->if i==dim_lit sum(length.(catmonster)) else length(exinds[1][i]) end, N)

        #And instantiate the type
        arr_type=typeof(arrays)
        new{dim_lit, my_eltype, N, arr_type, N-1, catlen}(arrays, catmonster, otherind, indbounds, mysizes)
    end
end

Base.size(A::CatArray)=A.size

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

function catinds_to_normal(I, dim, indbounds)
    arr_num=binsearch(I[dim], indbounds)
    newind=I[dim]-indbounds[arr_num]+1
    return (arr_num, newind)
end

function Base.getindex(A::CatArray{dim,T,N}, I::Vararg{Int, N}) where {dim,T,N}
    arr_num, newind = catinds_to_normal(I, dim, A.indbounds)
    otherinds=A.other_indices
    catind=A.catdim_indices
    return getindex(A.arrays[arr_num], (if i < dim otherinds[i][I[i]] elseif i > dim otherinds[i-1][I[i]] else catind[arr_num][newind] end for i in 1:N)...)
end

function Base.setindex!(A::CatArray{dim,T,N}, v, I::Vararg{Int, N}) where {dim,T,N}
    arr_num, newind = catinds_to_normal(I, dim, A.indbounds)
    otherinds=A.other_indices
    catind=A.catdim_indices
    return setindex!(A.arrays[arr_num], v, (if i < dim otherinds[i][I[i]] elseif i > dim otherinds[i-1][I[i]] else catind[arr_num][newind] end for i in 1:N)...)
end

end # module
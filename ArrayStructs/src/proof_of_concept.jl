using Unrolled, StaticArrays, Setfield

import Base.length

len = 20

fnames=(:($(Symbol("a$i"))::T) for i in 1:len)

name=Symbol("Static$len")

abstract type ArrayStruct{T,Dim} <: AbstractArray{T,Dim} end

Base.size(x::ArrayStruct) = x.size

Base.getindex(x::ArrayStruct, i::Integer) = getfield(x, i)

#TODO: Understand internals to make setfield without calling constructors

Base.setindex(x::ArrayStruct, v, i::Integer) = setproperties

@eval begin 
struct $name{T,Dim} <: ArrayStruct{T,Dim}
    $(fnames...)
    size::NTuple{Dim, Int}
    function $name(itr; type=nothing, dims = nothing)
        if isnothing(dims) dims = tuple(length(args)) end
        length(args) == len || throw(ArgumentError("Incorrect Length"))
        length(args) == prod(dims) || throw(ArgumentError("Dimension sizes and lengths do not match"))
        if isnothing(type) type = eltype(args) end
        new{type, length(dims)}(itr..., dims)
    end
end
length(x::$name) = len
end

arr = reshape(1:9, 3, 3).^2

foo=Static20(1:20...)
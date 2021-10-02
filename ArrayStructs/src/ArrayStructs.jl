module ArrayStructs

using StaticArrays, Unrolled

abstract type ArrayStruct{N,T,D} <: FieldArray{N,T,D} end

function ArrayStruct(elements...)

    elly_type=promote_type(unrolled_map(typeof, elements)...)


end

function ArrayStruct(length, ellytype=Float64)

end # module

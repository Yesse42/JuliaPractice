module Trees

export Leaf, Node, Tree, LeafOrNode

const DataViewType{T, Parent}=SubArray{T, 2, Parent, Tuple{Vector{Int64}, Base.Slice{Base.OneTo{Int64}}}, false}

struct LeafInfo
    homogenous::Bool
    rand_return::Bool
end

struct Leaf{T, Parent}
    data::DataViewType{T, Parent}
    avg::Union{Nothing, T}
    leaf_info::LeafInfo
end

const LeafOrNode{T, Parent} = Union{Leaf{T, Parent}, Node{T, Parent}}

struct Node{T, Parent}
    left_child::LeafOrNode{T,Parent}
    right_child::LeafOrNode{T,Parent}
    data::DataViewType{T, Parent}
    splitvar_idx::Int
    split_thresh::T
    depth::Int
    leaf_info::LeafInfo
end

struct Tree{T, Parent, LT, EvalF}
    root_node::LeafOrNode{T, Parent}
    ltfunc::LT
    splitevalfunc::EF
    leaf_info::LeafInfo
end

end
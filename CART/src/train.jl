module Train

export create

using StatsBase

function NodeOrLeaf(data)

function create(dependent::AbstractVector{T}, independent::AbstractMatrix{T}; 
    n_features=fld(size(independent, 2),3), max_depth=Inf, min_leaf_samp=1, leaf_eval=:avg) where T
    randvars=StatsBase.sample(axes(independent, 2), n_features; replace=false)
    return Tree(NodeOrLeaf())
end
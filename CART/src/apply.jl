module Apply

export apply

include("trees.jl")

using .Trees

function recursive_apply(leaf::Leaf, values, ltfunc)
    if leaf.leaf_info.rand_return
        return rand(leaf.data)
    else
        return leaf.avg
    end
end

function recursive_apply(node::Node, values, ltfunc)
    if ltfunc(node.split_thresh, values[node.splitvar_idx])
        recursive_apply(node.right_child, values, ltfunc)
    else
        recursive_apply(node.left_child, values, ltfunc)
    end
end

function apply(tree::Tree, values)
    recursive_apply(tree.root_node, values, tree.ltfunc)
end

end
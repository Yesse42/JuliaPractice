using Pkg; Pkg.activate("./MyProduct")
using MyProduct

function iterview(iter)
    next = iterate(iter)
    while next !== nothing
        (item, state) = next
        display(next)
        next = iterate(iter, state)
    end
end
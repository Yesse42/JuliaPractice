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

iterview(MyProd(1:5,5:-1:1))
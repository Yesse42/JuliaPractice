path = @__DIR__

cd(path)

display(pwd())

using Pkg; Pkg.activate("../../Weasel/")

using Weasel

genes=push!(collect('A':'Z'), ' ')

evolve(genes, collect("METHINKS IT A WEASEL"), update_func=x->println(String(x)))
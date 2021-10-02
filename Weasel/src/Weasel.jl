module Weasel

export evolve

function shuffle(init_specimen, genepool, mut_chance)

    out=similar(init_specimen)

    mut_rands=rand(Float64, length(init_specimen)) .≤ mut_chance

    sames = (!).(mut_rands)

    out[mut_rands] .= rand.(Ref(genepool))

    out[sames] .= init_specimen[sames]

    return out
end

function evolve(genepool, target, init_specimen=rand(genepool, length(target)); metric_func = ((x,y)->Int(!isequal(x,y))), update_func=println, mutation_chance=0.05, generation_size=100)
    
    all(in.(target, Ref(genepool))) && all(in.(init_specimen, Ref(genepool))) || throw(ArgumentError("All members of input or target are not in genepool"))
    length(target) ≠ length(init_specimen) && throw(ArgumentError("Lengths of target and initial specimen must match"))

    n_iter=0
    while any(target .≠ init_specimen)
        
        new_gen = [shuffle(init_specimen, genepool, mutation_chance) for i in 1:generation_size]

        init_specimen=new_gen[ argmin([ sum(metric_func.(new_member, target)) for new_member in new_gen ]) ]

        update_func(init_specimen)
        n_iter+=1
    end

    return n_iter
end

end # module

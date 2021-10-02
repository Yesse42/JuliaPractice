"""
    Use the syntax @cloop begin (init; update; end_cond) body end. 
    This loop will leak any variables in the init expr into its surrounding scope.
    However, everything else will remain in a separate local scope.
    Perhaps in the future I will add something to detect whether the variable is already initialized; 
    If it is then it behaves as now, modifying that variable, but if it isn't allocated then its in a local scope and so does not leak 
    If @cloop is used in the global scope, any changes to variables created in init in the body 
    must be annotated with global
"""
macro cloop(expr::Expr)
    @assert expr.head == :block
    quote
        $(expr.args[2].args[1]) # init expr
        while $(expr.args[2].args[5]) #end condition expr
            $(expr.args[4:end]...)
            $(expr.args[2].args[3]) # update expr
        end
    end
end

function main()
    @cloop begin (k=2^40;k=k÷2; k>=1)
        print(k, "\n")
    end
end

@code_native main()
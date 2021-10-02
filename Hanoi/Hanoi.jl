using DataStructures: eachindex
import Base.getindex
using DataStructures

const moves=Ref{Int64}(0)

"Define the data structure"
struct HanoiHell{T<:Integer}
    t1::Vector{T}
    t2::Vector{T}
    t3::Vector{T}
end

function show(tower::HanoiHell)
    println()
    lengths=length.([tower.t1,tower.t2,tower.t3])
    maxlen=maximum(lengths)
    for i in maxlen:-1:1
        for (j,len) in enumerate(lengths)
            if i<=len
                print("$(tower[j][i]) ")
            else
                print("- ")
            end
        end
        println()
    end
    println()
end

function HanoiHell(maxheight::T,startpos) where {T<:Integer}
    t1=Vector{T}(); t2=Vector{T}(); t3=Vector{T}()
    range=T.(reverse(1:maxheight))
    if startpos==1 t1=range elseif startpos==2 t2=range elseif startpos==3 t3=range end
    return HanoiHell(t1,t2,t3)
end

function not_either_tower(towers...)
    return first(filter(x->!in(x,towers),1:3))
end

getindex(tower::HanoiHell,int::Integer) = getfield(tower, int)

function recursive_move!(tower::HanoiHell{T},start,finish,npops,vis) where {T<:Integer}
    if npops==1
        hoop=pop!(tower[start])
        push!(tower[finish],hoop)
        moves[]=moves[]+1
        vis && show(tower)
    else
        place1=not_either_tower(start,finish)
        recursive_move!(tower,start,place1,npops-1,vis)
        bottom_hoop=pop!(tower[start])
        push!(tower[finish],bottom_hoop)
        vis && show(tower)
        moves[]=moves[]+1
        recursive_move!(tower,place1,finish,npops-1,vis)
    end
    return nothing
end

function move_tower(maxheight::T,start,finish;vis=true) where {T<:Integer}
    tower=HanoiHell(maxheight,start)
    vis && show(tower)
    recursive_move!(tower,start,finish,maxheight,vis)
end

move_tower(10,1,3)

println("The number of moves: $(moves[])")
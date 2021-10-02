using StructArrays

const treestring=split("""75
95 64
17 47 82
18 35 87 10
20 04 82 47 65
19 01 23 75 03 34
88 02 77 73 07 63 67
99 65 04 28 06 16 70 92
41 41 26 56 83 40 80 70 33
41 48 72 33 47 32 37 16 94 29
53 71 44 65 25 43 91 52 97 51 14
70 11 33 28 77 73 17 78 39 68 17 57
91 71 52 38 17 14 91 43 58 50 27 29 48
63 66 04 68 89 53 67 30 73 16 69 87 40 31
04 62 98 27 23 09 70 98 73 93 38 53 60 04 23""",'\n')

const tree=Tuple(Tuple(parse.(Int,split(row,' '))) for row in treestring)

mutable struct TreeStreak
    value::Int
    index::Int
end

function get_max_sum()
    paths=Array{TreeStreak}(undef,0)
    for row in tree
        rowlen=length(row)
        if rowlen==1
            push!(paths,TreeStreak(row[1],1))
            continue
        end
        safeitr=copy(paths)
        for path in safeitr
            idx=path.index
            push!(paths,TreeStreak(path.value+row[idx+1],idx+1))
            path.value=path.value+row[idx]
        end
        #And now filter out duplicates
        idxs=(x->x.index).(paths)
        vals=(x->x.value).(paths)
        mask=[!any((path.index .== idxs) .* (path.value .< vals)) for path in paths]
        paths=paths[mask]
    end
    vals=(x->x.value).(paths)
    return paths[argmax(vals)]
end

get_max_sum()
using Memoize

@memoize function lattice_paths(d1,d2)
    if d1==0 || d2==0
        return 1
    else
        return lattice_paths(d1-1,d2)+lattice_paths(d1,d2-1)
    end
end

lattice_paths(20,20)
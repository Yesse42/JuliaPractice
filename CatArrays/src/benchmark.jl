cd("/Users/jerobinett/Desktop/JuliaPractice/CatArrays/src")

include("CatArrays.jl")

using BenchmarkTools, LazyArrays, CatViews

import ProfileSVG as PSVG

arrs=[rand(1000, 1000) for i in 1:10]

mine=CatArray(arrs...; dim=Val(2))

lazyarrs=LazyArrays.Hcat(arrs...)

catviews=CatView(arrs...)


if true
    println("\nTest 1: Random Access")
    test(array)=sum(rand(array) for i in 1:100)
    println("\nCatViews")
    display(@benchmark test($catviews))
    println("\nLazyArrays")
    display(@benchmark test($lazyarrs))
    println("\nHomebrew Implementation")
    display(@benchmark test($mine))
end

if true
    println("\nTest 2: Sum (iterate through the array)")
    test(array)=sum(array)
    println("\nCatViews")
    display(@benchmark test($catviews))
    println("\nLazyArrays")
    display(@benchmark test($lazyarrs))
    println("\nHomebrew Implementation")
    display(@benchmark test($mine))
end

if true
    println("\nTest 3: Collect")
    test(array)=collect(array)
    println("\nCatViews")
    display(@benchmark test($catviews))
    println("\nLazyArrays")
    display(@benchmark test($lazyarrs))
    println("\nHomebrew Implementation")
    display(@benchmark test($mine))
end

if true
    println("\nTest 4: Deepcopy")
    test(array)=deepcopy(array)
    println("\nCatViews")
    display(@benchmark test($catviews))
    println("\nLazyArrays")
    display(@benchmark test($lazyarrs))
    println("\nHomebrew Implementation")
    display(@benchmark test($mine))
end

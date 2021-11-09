using Revise, Plots
gr()
import Revise.includet
includet("ModelTypes.jl")
includet("SpectralOps.jl")
includet("BarotropicDynamics.jl")
#Intellisense hack
if false
    begin
    include("ModelTypes.jl")
    include("SpectralOps.jl")
    include("BarotropicDynamics.jl")
    end
end

using .ModelTypes, .SpectralOps, .BarotropicDynamics
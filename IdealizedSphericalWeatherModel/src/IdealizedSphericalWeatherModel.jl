module IdealizedSphericalWeatherModel

include("ModelTypes.jl")
include("SpectralOps.jl")
include("BarotropicDynamics.jl")

using .ModelTypes, .SpectralOps, .BarotropicDynamics

end # module

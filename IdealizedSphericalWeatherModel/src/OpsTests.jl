using Revise, Plots
gr()
import Revise.includet
includet("ModelTypes.jl")
includet("SpectralOps.jl")
includet("BarotropicDynamics.jl")
#Intellisense hack
if false
    include("ModelTypes.jl")
    include("SpectralOps.jl")
    include("BarotropicDynamics.jl")
end

using .ModelTypes, .SpectralOps, .BarotropicDynamics

#See if this errors
testmodel=BaroModel(BaroParams(Float32; mwnum=200))

curmod=testmodel.now
pcalc=testmodel.pcalc
dim=testmodel.dims

#Now do a basic transform
spec=curmod.specucos
spec[1:7,1:7] .= Complex.(3 .*randn.(),0.25.*randn.())

display(heatmap(abs.(spec); title="Initial Spectral"))

#Transform to the fourier

four=testmodel.workspace.four[1]
spectofourier!(four, spec; plmarr=pcalc.PLM, sinlats=dim.sinlat, zonws=dim.zon, totws=dim.tot)

display(heatmap(abs.(four); title="Fourier"))

#Transform to the grid
grid=curmod.griducos

fouriertogrid!(grid, four; backplan = pcalc.BFFTPlan)
gridplot=heatmap(grid; title="Grid", color=:magma)
display(gridplot)

#Now back to the fourier

otherfour=deepcopy(four)

gridtofourier!(otherfour, grid; forwardplan = pcalc.FFTPlan, zonws=dim.zon)

display(heatmap(abs.(otherfour); title="Fourier Again"))

#And back to the spectral again

otherspec=deepcopy(spec)

fouriertospec!(otherspec, otherfour; weights=dim.weights, totws=dim.tot, zonws=dim.zon, plmarr=pcalc.PLM)

display(heatmap(abs.(otherspec); title="Spectral Again"))

#Now test vor div again

savefig(gridplot, "~/Downloads/weird.png")

gridplot
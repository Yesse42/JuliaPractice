include("testheader.jl")

#See if this errors
testmodel=BaroModel(BaroParams(Float32; mwnum=100))

curmod=testmodel.now
pcalc=testmodel.pcalc
dim=testmodel.dims

#Now do a basic transform
spec=curmod.specucos
spec[1:5,1:5] .= rand.(ComplexF64)

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

gridtofourier!(otherfour, grid; backplan = pcalc.BFFTPlan, zonws=dim.zon)

display(heatmap(abs.(otherfour); title="Fourier Again"))

#And back to the spectral again

otherspec=deepcopy(spec)

fouriertospec!(otherspec, otherfour; weights=dim.weights, totws=dim.tot, zonws=dim.zon, plmarr=pcalc.PLM)

display(heatmap(abs.(otherspec); title="Spectral Again"))

savefig(gridplot, "~/Downloads/weird.png")

gridplot
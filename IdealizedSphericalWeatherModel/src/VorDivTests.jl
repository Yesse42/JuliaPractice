include("testheader.jl")

using Parameters

const Ops=SpectralOps

testmodel=BaroModel(BaroParams(Float64; mwnum=20))

@unpack now, params, dims, pcalc, params, workspace = testmodel

now.specstream[4,3] = 1+1im

#Transform uwind

cos2specmerideriv!(now.specucos, now.specstream; epstable=pcalc.ϵTable, totws=dims.tot, zonws=dims.zon)

spectogrid!(now.griducos, workspace.four[1], now.specucos; backplan=pcalc.BFFTPlan,
plmarr=pcalc.PLM, sinlats=dims.sinlat, zonws=dims.zon, totws=dims.tot)

now.griducos ./= -1 .* pcalc.cosθvec

display(heatmap(now.griducos, title="u wind"))

#Transform v wind

speczonalderiv!(now.specvcos, now.specstream; zonws=dims.zon)

spectogrid!(now.gridvcos, workspace.four[1], now.specvcos; backplan=pcalc.BFFTPlan,
plmarr=pcalc.PLM, sinlats=dims.sinlat, zonws=dims.zon, totws=dims.tot)

now.gridvcos ./= pcalc.cosθvec

display(heatmap(now.gridvcos, title="v wind"))

spectogrid!(workspace.grid[1], workspace.four[1], now.specstream; backplan=pcalc.BFFTPlan,
plmarr=pcalc.PLM, sinlats=dims.sinlat, zonws=dims.zon, totws=dims.tot)

display(heatmap(workspace.grid[1], title="StreamFunction (negative means counterclockwise winds"))

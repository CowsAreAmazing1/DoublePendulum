using DelimitedFiles
using GLMakie
include("Vars.jl")
using .Vars
set_theme!(theme_dark())

xs = range(xrange..., res)
ys = range(yrange..., res)
zs = readdlm("geet.csv", '\t', Float32, '\n')

zs .-= minimum(zs)
zs ./= maximum(zs)
zs = 1 .- zs
zs = exp.(zs)

f = Figure(size = (800, 800))
axs = Axis(f[1,1], aspect = DataAspect())

heatmap!(axs, xs, ys, zs, colormap = :magma)
hidedecorations!.(axs)
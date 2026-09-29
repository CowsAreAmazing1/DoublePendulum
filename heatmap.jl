using DelimitedFiles
using GLMakie
include("Vars.jl")
using .Vars
set_theme!(theme_dark())

xs = range(Vars.xrange..., Vars.res)
ys = range(Vars.yrange..., Vars.res)
zs = readdlm("DATA.csv", '\t', Float32, '\n')

zs .-= minimum(zs)
zs ./= maximum(zs)
zs = 1 .- zs
# zs = exp.(zs)
zs .^= 3

f = Figure(size=(800, 800))
axs = Axis(f[1, 1], aspect=DataAspect())

heatmap!(axs, xs, ys, zs, colormap=:linear_kry_0_97_c73_n256)
hidedecorations!.(axs)

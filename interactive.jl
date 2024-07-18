using DelimitedFiles
include("pendulum.jl")
include("Vars.jl")
set_theme!(theme_dark())

using .Vars

xs = range(xrange..., res)
ys = range(yrange..., res)
zs = readdlm("geet.csv", '\t', Float32, '\n')

n1 = xs[findmin(zs)[2][1]]
n2 = ys[findmin(zs)[2][2]]

zs .-= minimum(zs)
zs ./= maximum(zs)
zs = 1 .- zs
zs .^= 5
#zs = 1 .- zs

x1 = Observable(Int32)
y1 = Observable(Int32)

f = Figure(size = (1200, 600))
axs = [Axis(f[1,i], aspect = DataAspect()) for i in 1:2]

heatmap!(axs[1], xs, ys, zs, colormap = :linear_kry_0_97_c73_n256)
hidedecorations!.(axs)

deregister_interaction!.(axs, :rectanglezoom)


ls = Point{2, Float32}[]
ls = Observable(ls)
ls2 = Point{2, Float32}[]
ls2 = Observable(ls2)
p1 = Pendulum(0,0)
poses = positionObservable(p1)


function runner()
    while true
        for _ in 1:3
            update(p1, 0, 0.005)

            push!(ls2[], poses[][1])
            push!(ls[], poses[][2])
        end
        ls[] = ls[][end-min(length(ls[])-1, 10000):end]
        ls2[] = ls2[][end-min(length(ls2[])-1, 10000):end]
        notify(ls)
        sleep(1/500)
    end
end

display(f)
@async runner()

on(events(axs[1]).mousebutton) do event
    x, y = mouseposition(axs[1])
    if x < xrange[1] || x > xrange[2] || y < yrange[1] || y > yrange[2]
        return
    end

    if event.button == Mouse.left && event.action == Mouse.press
        empty!(axs[2])


        global p1 = Pendulum(x, y)
        global poses = positionObservable(p1)
        global ls = Point{2, Float32}[]
        global ls = Observable(ls)
        global ls2 = Point{2, Float32}[]
        global ls2 = Observable(ls2)

        push!(ls2[], poses[][1])
        push!(ls[], poses[][2])
        
        scatter!(axs[2], Point2f(0,0), color = :white)
        arc!(axs[2], Point(0), 1, 0, 2pi, linewidth = 0.2, color = :white)
        arc!(axs[2], Point(0), 2, 0, 2pi, linewidth = 0.2, color = :white)
        
        lines!(axs[2], ls)
        lines!(axs[2], ls2)
        axs[2].limits = (-2.1, 2.1, -2.1, 2.1)
        
        lines!(axs[2], @lift([Point2f(0), $(poses)[1]]), color = :white)
        lines!(axs[2], @lift([$(poses)[1], $(poses)[2]]), color = :white)

        scatter!(axs[2], poses)

        axs[2].aspect = DataAspect()

        #=
        for t in 1:1000
            for _ in 1:10
                update(p1, t, 0.001)
                update(p2, t, 0.001)
                push!(ls[][1], poses[1][][2])
                push!(ls[][2], poses[2][][2])
            end
            ls[][1] = ls[][1][end-min(length(ls[][1])-1, 1000):end]
            ls[][2] = ls[][2][end-min(length(ls[][2])-1, 1000):end]
            notify(ls)
            sleep(1/60)
        end
        =#
    end
end

include("pendulum.jl")

@time begin
    n1, n2 = pi/2 + pi * rand(), pi/2 + pi * rand()
    a = Pendulum.(n1 .+ range(0, 0.01, 200), n2)
    @time sol = full_sim.(a, Ref((0.0, 15.0)))
    b = full_position.(a, sol)

    t = Observable(1)
    s = @lift(map(x -> x[2][1:($t)], b))

    f, ax = scatter(Point2f(0), color=:white, figure=(size=(600, 600),))
    series!(ax, s, color=Makie.resample_cmap(:autumn1, length(a)), linewidth=0.1)
    ax.limits = (-2.1, 2.1, -2.1, 2.1)
    ax.aspect = DataAspect()

    arms = @lift(map(i -> [Point2f(0), i[1][$t], i[2][$t]], b))
    series!(ax, arms, color=Makie.resample_cmap(:viridis, length(arms[])))

    #t[] = length(b[1][1])
    f
end

for i in eachindex(b[1][1])
    t[] = i
    sleep(1/120)
end


f, ax = lines(b[1][2])
lines!(ax, b[2][2])
ax.limits = (-2.1, 2.1, -2.1, 2.1)
ax.aspect = DataAspect()



f, ax = scatter(Point2f(0), color=:white, figure=(size=(1000, 1000),))

for _ in 1:3
    @time begin
        n1, n2 = pi/2 + pi * rand(), pi/2 + pi * rand()
        a = Pendulum.(n1 .+ range(0, 0.01, 500), n2)
        @time sol = full_sim.(a, Ref((0.0, 15.0)))
        b = full_position.(a, sol)

        t = Observable(1)
        s = @lift(map(x -> x[2][1:($t)], b))

        series!(ax, s, color=Makie.resample_cmap(:hsv, length(a)), linewidth=0.02)
        ax.limits = (-2, 2, -2, 2)
        ax.aspect = DataAspect()

        #arms = @lift(map(i -> [Point2f(0), i[1][$t], i[2][$t]], b))
        #series!(ax, arms, color = Makie.resample_cmap(:viridis, length(arms[])))

        t[] = length(b[1][1])
        f
    end
end

hidedecorations!(ax)
tightlimits!(ax)

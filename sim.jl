include("pendulum.jl")

begin
    p1 = Pendulum(pi/2, 0)
    pos1 = positionObservable(p1)

    p2 = Pendulum(pi/2 + 0.0001, 0)
    pos2 = positionObservable(p2)


    ps = [p1]
    poses = positionObservable.(ps)

    ls = Vector{Point{2, Float32}}[]
    ls = Observable(ls)
    for i in poses
        push!(ls[], [i[][2]])
    end

    sim, simax = scatter(Point2f(0,0))

    lines!(@lift($(ls)[1]))
    #lines!(@lift($(ls)[2]))
    simax.limits = (-2.5, 2.5, -2.5, 2.5)

    lines!(@lift([Point2f(0), $(pos1)[1]]), color = :black)
    lines!(@lift([$(pos1)[1], $(pos1)[2]]), color = :black)
    #lines!(@lift([Point2f(0), $(pos2)[1]]), color = :black)
    #lines!(@lift([$(pos2)[1], $(pos2)[2]]), color = :black)

    for i in poses
        scatter!(i)
    end

    simax.aspect = DataAspect()
    sim
end


@time for q in 1:1000
    for _ in 1:10
        update(p1, q, 0.001)
        #update(p2, q, 0.001)
        push!(ls[][1], pos1[][2])
        #push!(ls[][2], pos2[][2])
    end
    #ls[][1] = ls[][1][end-min(length(ls[][1])-1, 100000):end]
    #ls[][2] = ls[][2][end-min(length(ls[][2])-1, 100000):end]
    #notify(ls)
    #sleep(1/60)
end
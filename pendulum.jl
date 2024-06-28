using GLMakie, DifferentialEquations

struct Pendulum
    m1::Observable{Float32}
    m2::Observable{Float32}
    l1::Observable{Float32}
    l2::Observable{Float32}
    g::Observable{Float32}
    state::Observable{Vector{Float32}}

    Pendulum(a1, a2; m1 = 1.0, m2 = 1.0, l1 = 1.0, l2 = 1.0) = begin
        new(
            Observable(m1),
            Observable(m2),
            Observable(l1),
            Observable(l2),
            Observable(9.81),
            Observable([0, 0, a1, a2])
        )
    end
end

function G(p::Pendulum, y, t)
    a1d, a2d = y[1], y[2]
    a1, a2 = y[3], y[4]

    m11, m12 = (p.m1[]+p.m2[])*p.l1[], p.m2[]*p.l2[]*cos(a1-a2)
    m21, m22 = p.l1[]*cos(a1-a2), p.l2[]
    m = [[m11 m12]; [m21 m22]]

    f1 = -p.m2[]*p.l2[]*a2d*a2d*sin(a1-a2) - (p.m1[]+p.m2[])*p.g[]*sin(a1)
    f2 = p.l1[]*a1d*a1d*sin(a1-a2) - p.g[]*sin(a2)
    f = [f1 f2]
    accel = inv(m) * f'

    return [accel..., a1d, a2d]
end

function update(p::Pendulum, t, dt)
    function RK4_step(y, t, dt)
        k1 = G(p, y,           t)
        k2 = G(p, y+0.5*k1*dt, t+0.5*dt)
        k3 = G(p, y+0.5*k2*dt, t+0.5*dt)
        k4 = G(p, y+k3*dt,     t+dt)

        return dt * (k1 + 2*k2 + 2*k3 + k4)/6
    end

    p.state[] += RK4_step(p.state[], t, dt)

end

function position(p::Pendulum)
    p1 = Point2f(sin(p.state[][3]), cos(p.state[][3]))
    p2 = Point2f(p1[1] + sin(p.state[][4]), p1[2] + cos(p.state[][4]))

    return p1, p2
end

function positionObservable(p::Pendulum)
    p1 = @lift(Point2f(sin($(p.state)[3]), -cos($(p.state)[3])))
    p2 = @lift(Point2f($(p1)[1] + sin($(p.state)[4]), $(p1)[2] - cos($(p.state)[4])))

    return @lift([$p1, $p2])
end

function full_sim(p::Pendulum, tspan::Tuple{Float64, Float64})
    function double_pendulum(du, u, p1, t)
        du[3] = u[1]
        du[1] = (-p.g[]*(2p.m1[]+p.m2[])sin(u[3]) - p.m2[]*p.g[]*sin(u[3]-2u[4]) - 2sin(u[3]-u[4])*p.m2[]*(p.l2[]*u[2]^2 + p.l1[]*cos(u[3]-u[4])*u[1]^2)) / (p.l1[]*(2p.m1[]+p.m2[] - p.m2[]*cos(2u[3]-2u[4])))
        du[4] = u[2]
        du[2] = 2sin(u[3]-u[4])*((p.m1[]+p.m2[])*p.l1[]*u[1]^2 + p.g[]*(p.m1[]+p.m2[])*cos(u[3]) + p.l2[]*u[2]^2*p.m2[]*cos(u[3]-u[4])) / (p.l2[]*(2p.m1[]+p.m2[] - p.m2[]*cos(2u[3]-2u[4])))
    end

    double_pendulum_problem = ODEProblem(double_pendulum, p.state[], tspan)
    solve(double_pendulum_problem, abstol = 1e-18)
end

function full_position(p::Pendulum, sol::DESolution; dt = 0.01, l1 = p.l1[], l2 = p.l2[], vars = (3, 4))
    u = sol.t[1]:dt:sol.t[end]

	p1 = map(x -> x[vars[1]], sol.(u))
    p2 = map(y -> y[vars[2]], sol.(u))

    x1 = l1 * sin.(p1)
    y1 = l1 * -cos.(p1)
    [
      Point2f.(x1, y1),
      Point2f.(x1 + l2 * sin.(p2), y1 - l2 * cos.(p2))
    ]
end
#=
@time begin
    n1, n2 = pi/2 + pi * rand(), pi/2 + pi * rand()
    a = Pendulum.(n1 .+ range(0, 0.01, 2), n2);
    @time sol = full_sim.(a, Ref((0.0, 15.0)));
    b = full_position.(a, sol);

    t = Observable(1)
    s = @lift(map(x -> x[2][1:$t], b))
    
    f, ax = scatter(Point2f(0), color = :white, figure = (size = (600,600),))
    series!(ax, s, color = Makie.resample_cmap(:autumn1, length(a)), linewidth = 0.1)
    ax.limits = (-2.1, 2.1, -2.1, 2.1); ax.aspect = DataAspect()

    arms = @lift(map(i -> [Point2f(0), i[1][$t], i[2][$t]], b))
    series!(ax, arms, color = Makie.resample_cmap(:viridis, length(arms[])))

    #t[] = length(b[1][1])
    f
end

for i in eachindex(b[1][1])
    t[] = i
    sleep(1/60)
end


f, ax = lines(b1[2])
lines!(ax, b2[2])
ax.limits = (-2.1, 2.1, -2.1, 2.1)
ax.aspect = DataAspect()









f, ax = scatter(Point2f(0), color = :white, figure = (size = (1000,1000),))

for _ in 1:10
    @time begin
        n1, n2 = pi/2 + pi * rand(), pi/2 + pi * rand()
        a = Pendulum.(n1 .+ range(0, 0.01, 500), n2);
        @time sol = full_sim.(a, Ref((0.0, 15.0)));
        b = full_position.(a, sol);

        t = Observable(1)
        s = @lift(map(x -> x[2][1:$t], b))
        
        series!(ax, s, color = Makie.resample_cmap(:hsv, length(a)), linewidth = 0.02)
        ax.limits = (-2, 2, -2, 2); ax.aspect = DataAspect()

        #arms = @lift(map(i -> [Point2f(0), i[1][$t], i[2][$t]], b))
        #series!(ax, arms, color = Makie.resample_cmap(:viridis, length(arms[])))

        t[] = length(b[1][1])
        f
    end
end

hidedecorations!(ax)
tightlimits!(ax)

=#
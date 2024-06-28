include("pendulum.jl")
using LinearAlgebra

function grabPerturbed(di, df, perturbed_state, initial_state)
    return initial_state + (di * (perturbed_state - initial_state)) / df
end

function tempLyapunov(di, df)
    return log(abs(df/di))
end

function lyapunovCalculator(theta1, theta2)
    dt = 0.01
    totalTime = 25
    time = 0:dt:totalTime
    divisor = 20

    lyapunovExponents = []
    initial = Pendulum(theta1, theta2)
    perturbed = Pendulum(theta1 + 0.001, theta2)
    distanceInitial = norm(perturbed.state[] - initial.state[])

    isol = full_sim(initial, (0.0, 25.0))
    psol = full_sim(perturbed, (0.0, 25.0))

    for (i, t) in enumerate(time[1:divisor:end])
        ps = []

        distanceFinal = norm(perturbed.state[] - initial.state[])
        push!(lyapunovExponents, tempLyapunov(distanceInitial, distanceFinal))
        perturbed.state[] = grabPerturbed(distanceInitial, distanceFinal, perturbed.state[], initial.state[])
        distanceInitial = norm(perturbed.state[] - initial.state[])
    end

    return sum(lyapunovExponents) * (1/totalTime)
end


initial = Pendulum(pi/2, 0)
isol = full_sim(initial, (0.0, 25.0))
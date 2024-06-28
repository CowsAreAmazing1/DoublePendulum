include("lyapunov.jl")
include("Vars.jl")
using DelimitedFiles, ProgressMeter
using .Vars


println("$(Threads.nthreads()) running")


xs = range(xrange..., res)
ys = range(yrange..., res)
zs = zeros(length(xs), length(ys))

@showprogress Threads.@threads for i in eachindex(ys)
    #println("Thread $(Threads.threadid()) working on y value $(i)")
    for j in eachindex(xs)
        zs[CartesianIndex(j, i)] = lyapunovCalculator(xs[j], ys[i])
    end
end

#=
@showprogress Threads.@threads for i in eachindex(ys)
    #println("Thread $(Threads.threadid()) working on y value $(i)")
    for j in eachindex(xs)
        zs[CartesianIndex(j, i)] = lyapunovCalculator(xs[j], ys[i])
    end
end
=#

writedlm("geet.csv", zs)

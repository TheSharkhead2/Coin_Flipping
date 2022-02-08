include("functions.jl")
using .SimAnnealCoin

@time x = simulation(1000, (1.0-0.26887434151226475))

println(x)

# sim_anneal(1000.0, 0.001, 1, 0.001)
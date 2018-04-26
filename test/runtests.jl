using Modof, Modolib, CPLEXModoalgos, JuMP
using Base.Test

# write your own tests here

model = ModoModel()
@variable(model, x[1:4], Bin)
objective!(model, 1, :Min, x[1]+x[2]+x[3]+x[4])
objective!(model, 2, :Min, -x[1]-x[2]-x[3]-x[4])
@constraint(model, x[1]+x[2]+x[3]+x[4] <= 3)

@time solution = compute_approximate_frontier_using_cplex(model)

println("Hypervolume = $(compute_hypervolume_of_a_discrete_frontier(wrap_sols_into_array(solution)))")

model = ModoModel()
@variable(model, x[1:4], Bin)
objective!(model, 1, :Min, x[1]+x[2]+x[3]+x[4])
objective!(model, 2, :Min, -x[1]-x[2]-x[3]-x[4])
objective!(model, 3, :Min, x[1]+2x[2]+3x[3]+4x[4])
@constraint(model, x[1]+x[2]+x[3]+x[4] <= 3)

@time solution = compute_approximate_frontier_using_cplex(model)

println("Hypervolume = $(compute_hypervolume_of_a_discrete_frontier(wrap_sols_into_array(solution)))")

model = ModoModel()
@variable(model, x[1:2], Bin)
@variable(model, y[1:2] >= 0.0)
objective!(model, 1, :Min, x[1] + x[2] + y[1] + y[2])
objective!(model, 2, :Min, -x[1] - x[2] - y[1] - y[2])
@constraint(model, x[1] + x[2] <= 1) 
@constraint(model, 2.72y[1] + 7.39y[2] >= 1) 

@time solution = compute_approximate_frontier_using_cplex(model)

println("Hypervolume = $(compute_hypervolume_of_a_discrete_frontier(wrap_sols_into_array(solution)))")

model = ModoModel()
@variable(model, x[1:2], Bin)
@variable(model, y[1:2] >= 0.0)
objective!(model, 1, :Min, x[1] + x[2] + y[1] + y[2])
objective!(model, 2, :Min, -x[1] - x[2] - y[1] - y[2])
objective!(model, 3, :Min, x[1] + 2x[2] + y[1] + 2y[2])
@constraint(model, x[1] + x[2] <= 1) 
@constraint(model, 2.72y[1] + 7.39y[2] >= 1)
 
@time solution = compute_approximate_frontier_using_cplex(model)

println("Hypervolume = $(compute_hypervolume_of_a_discrete_frontier(wrap_sols_into_array(solution)))")

@time solution = compute_approximate_frontier_using_cplex("Test.lp", [:Min, :Min])

println("Hypervolume = $(compute_hypervolume_of_a_discrete_frontier(wrap_sols_into_array(solution)))")

instance, true_non_dom_sols = read_bokp_xavier1("2KP50-1A") 
@time non_dom_sols = compute_approximate_frontier_using_cplex(instance)
hypervolume_gap, cardinality, max_coverage, avg_coverage, uniformity = compute_quality_of_apprx_frontier(wrap_sols_into_array(non_dom_sols), true_non_dom_sols)
println("Hypervolume Gap = $hypervolume_gap % \nCardinality = $cardinality % \nMaximum Coverage = $max_coverage \nAverage Coverage = $avg_coverage \nUniformity = $uniformity")

instance, true_non_dom_sols = read_bomip_hadi(1)
@time non_dom_sols = compute_approximate_frontier_using_cplex(instance)
hypervolume_gap, cardinality, max_coverage, avg_coverage, uniformity = compute_quality_of_apprx_frontier(wrap_sols_into_array(non_dom_sols), true_non_dom_sols, true)
println("Hypervolume Gap = $hypervolume_gap % \nCardinality = $cardinality % \nMaximum Coverage = $max_coverage \nAverage Coverage = $avg_coverage \nUniformity = $uniformity")

instance, true_non_dom_sols = read_mokp_kirlik(3, 10, 1)
@time non_dom_sols = compute_approximate_frontier_using_cplex(instance)
hypervolume_gap, cardinality, max_coverage, avg_coverage, uniformity = compute_quality_of_apprx_frontier(wrap_sols_into_array(non_dom_sols), true_non_dom_sols)
println("Hypervolume Gap = $hypervolume_gap % \nCardinality = $cardinality % \nMaximum Coverage = $max_coverage \nAverage Coverage = $avg_coverage \nUniformity = $uniformity")

instance = read_mombp_aritra_instance(3, 20, 1)
@time non_dom_sols = compute_approximate_frontier_using_cplex(instance)
println("Hypervolume = $(compute_hypervolume_of_a_discrete_frontier(wrap_sols_into_array(solution)))")

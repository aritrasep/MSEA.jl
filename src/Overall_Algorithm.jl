###############################################################################
#                                                                             #
#  This file is part of the julia module for Multi Objective Optimization     #
#  (c) Copyright 2017 by Aritra Pal, Hadi Charkhgard                          #
#                                                                             #
# This license is designed to guarantee freedom to share and change software  #
# for academic use, but restricting commercial firms from exploiting our      #
# knowhow for their benefit. The precise terms and conditions for using,      #
# copying, distribution, and modification follow. Permission is granted for   #
# academic research use. The license expires as soon as you are no longer a   # 
# member of an academic institution. For other uses, contact the authors for  #
# licensing options. Every publication and presentation for which work based  #
# on the Program or its output has been used must contain an appropriate      # 
# citation and acknowledgment of the authors of the Program.                  #
#                                                                             #
# The above copyright notice and this permission notice shall be included in  #
# all copies or substantial portions of the Software.                         #
#                                                                             #
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     #
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER         #
# DEALINGS IN THE SOFTWARE.                                                   #
#                                                                             #
###############################################################################

include("Generating_Feasible_Solutions.jl")
include("Initial_Start.jl")
include("Exploring_Queue_of_Rectangles.jl")

###########################################################################
# Overall Algorithm                                                       #
###########################################################################

@inbounds function msea(instance::Union{BOBPInstance, BOIPInstance}; feasible_solutions::Vector{BOPSolution}=BOPSolution[], fpbh::Float64=0.0, mdls::Int64=0, turn_off_cplex_heur::Bool=false, num::Int64=1, threads::Int64=1, cutting_direction::Int64=4, deterministic_exploration::Bool=true, minimum_dim::Bool=true, operations::Vector{Int64}=[1], approximation::Bool=false, ϵ::Float64=0.99, log_file_name::Union{String, Void}=nothing, timelimit::Float64=Inf, message::Bool=true)
    
    println("---------------------------------------------------------")
    println("                        MSEA v1.0")
    println("        Copyright (c) Aritra Pal, Hadi Charkhgard")
    println("---------------------------------------------------------")
    
    ###########################################################################
    ## Feasible Solutions                                                    ##
    ###########################################################################    
    
    t0 = time()
    feasible_solutions = generating_feasible_solutions(instance, feasible_solutions, fpbh, mdls, threads, message)
    t1 = time()
    
    ###########################################################################
    ## Initial Start                                                         ##
    ###########################################################################
    
    all(isinteger, instance.c1) && all(isinteger, instance.c2) ? ϵ = 0.99 : nothing
    non_dom_sols, feasible_solutions, rects_to_explore, ip_solved, cplex_time_1 = initial_start(instance, message, turn_off_cplex_heur, feasible_solutions, threads==1?num:threads, cutting_direction, ϵ)
    
    if timelimit <= time() - t0 || length(rects_to_explore) == 0
        return non_dom_sols, rects_to_explore, ip_solved, round(t1 - t0, 4), round(cplex_time_1, 4), round(time() - t1 - cplex_time_1, 4), round(time() - t0, 4)
    end
    
    ###########################################################################
    # Exploring the Queue of Rectangles                                       #
    ###########################################################################
    
    non_dom_sols, num_rects_explored, num_empty_rects_explored, rects_to_explore, ip_solved_, cplex_time_2 = explore_queue_of_rectangles(instance, turn_off_cplex_heur, rects_to_explore, non_dom_sols, feasible_solutions, operations, ϵ, deterministic_exploration, minimum_dim, approximation, timelimit - (time() - t0), message, log_file_name, threads)
    t2 = time()
    
    println("---------------------------------------------------------")
    println("Number of True Nondominated Points found = $(length(non_dom_sols))")
    println("Number of Rectangles explored            = $(num_rects_explored)")
    println("Number of Empty Rectangles explored      = $(num_empty_rects_explored)")
    println("Number of Rectangles left to explore     = $(length(rects_to_explore))")
    println("Number of IP Solved                      = $(ip_solved + ip_solved_)")
    println("---------------------------------------------------------")
    println("Total Time Taken by Heuristics           = $(round(t1 - t0, 4)) secs.")
    println("Total Time Taken by CPLEX                = $(round(cplex_time_1 + cplex_time_2, 4)) secs.")
    println("Total Time Taken by Julia                = $(round(t2 - t1 - cplex_time_1 - cplex_time_2, 4)) secs.")
    println("Total Time Taken                         = $(round(t2 - t0, 4)) secs.")
    println("---------------------------------------------------------")
    
    non_dom_sols, num_rects_explored, num_empty_rects_explored, rects_to_explore, ip_solved + ip_solved_, round(t1 - t0, 4), round(cplex_time_1 + cplex_time_2, 4), round(t2 - t1 - cplex_time_1 - cplex_time_2, 4), round(t2 - t0, 4)
end

###############################################################################
# Wrappers for JuMP Model                                                     #
###############################################################################

@inbounds function msea(model::JuMP.Model; feasible_solutions::Vector{BOPSolution}=BOPSolution[], fpbh::Float64=0.0, mdls::Int64=0, turn_off_cplex_heur::Bool=false, num::Int64=1, threads::Int64=1, cutting_direction::Int64=4, deterministic_exploration::Bool=true, minimum_dim::Bool=true, operations::Vector{Int64}=[1], approximation::Bool=false, ϵ::Float64=0.99, log_file_name::Union{String, Void}=nothing, timelimit::Float64=Inf, message::Bool=true)
    instance, sense = read_an_instance_from_a_jump_model(model)
    non_dom_sols, num_rects_explored, num_empty_rects_explored, rects_to_explore, ip_solved, heur_time, cplex_time, julia_time, total_time = msea(instance, feasible_solutions=feasible_solutions, fpbh=fpbh, mdls=mdls, threads=threads, message=message, turn_off_cplex_heur=turn_off_cplex_heur, num=num, cutting_direction=cutting_direction, ϵ=ϵ, deterministic_exploration=deterministic_exploration, minimum_dim=minimum_dim, operations=operations, approximation=approximation, timelimit=timelimit, log_file_name=log_file_name)
    if :Max in sense
        for i in 1:length(non_dom_sols), j in 1:2
            if sense[j] == :Max
                if j == 1
                    non_dom_sols[i].obj_val1 = -1.0*non_dom_sols[i].obj_val1
                else
                    non_dom_sols[i].obj_val2 = -1.0*non_dom_sols[i].obj_val2
                end
            end
        end
    end
    non_dom_sols, num_rects_explored, num_empty_rects_explored, rects_to_explore, ip_solved, heur_time, cplex_time, julia_time, total_time
end

###############################################################################
# Wrappers for LP and MPS File formats                                        #
###############################################################################

@inbounds function msea(filename::String, sense::Vector{Symbol}; feasible_solutions::Vector{BOPSolution}=BOPSolution[], fpbh::Float64=0.0, mdls::Int64=0, turn_off_cplex_heur::Bool=false, num::Int64=1, threads::Int64=1, cutting_direction::Int64=4, deterministic_exploration::Bool=true, minimum_dim::Bool=true, operations::Vector{Int64}=[1], approximation::Bool=false, ϵ::Float64=0.99, log_file_name::Union{String, Void}=nothing, timelimit::Float64=Inf, message::Bool=true)
    instance, sense = read_an_instance_from_a_jump_model(model)
    non_dom_sols, num_rects_explored, num_empty_rects_explored, rects_to_explore, ip_solved, heur_time, cplex_time, julia_time, total_time = msea(instance, feasible_solutions=feasible_solutions, fpbh=fpbh, mdls=mdls, threads=threads, message=message, turn_off_cplex_heur=turn_off_cplex_heur, num=num, cutting_direction=cutting_direction, ϵ=ϵ, deterministic_exploration=deterministic_exploration, minimum_dim=minimum_dim, operations=operations, approximation=approximation, timelimit=timelimit, log_file_name=log_file_name)
    if :Max in sense
        for i in 1:length(non_dom_sols), j in 1:2
            if sense[j] == :Max
                if j == 1
                    non_dom_sols[i].obj_val1 = -1.0*non_dom_sols[i].obj_val1
                else
                    non_dom_sols[i].obj_val2 = -1.0*non_dom_sols[i].obj_val2
                end
            end
        end
    end
    non_dom_sols, num_rects_explored, num_empty_rects_explored, rects_to_explore, ip_solved, heur_time, cplex_time, julia_time, total_time
end

###########################################################################
# Warming Up ESBOPIPCPLEX                                                 #
###########################################################################

function warmup_msea(threads::Int64=1; mdls::Bool=true)
    instance, true_frontier = read_bokp_xavier1("2KP50-1A")
    
    @time solutions = msea(instance, fpbh=0.0, mdls=0, threads=threads, message=false, turn_off_cplex_heur=false, num=2, cutting_direction=1, ϵ=0.99, deterministic_exploration=true, minimum_dim=true, operations=[1:14...])
    @time solutions = msea(instance, fpbh=-60.0, mdls=0, threads=threads, message=false, turn_off_cplex_heur=true, num=2, cutting_direction=2, ϵ=0.99, deterministic_exploration=false, minimum_dim=false, operations=[1:8...], approximation=true)
        
    if mdls
        try
            @time solutions = mdls_kp(instance)
        catch
            println("MDLS is not properly setup")
        end
    
        instance, true_frontier = read_bospp_xavier("2mis100_300A")
        try
            @elapsed mdls_bospp(instance)
        catch
            println("MDLS is not properly setup")
        end
    end
    
    model = ModoModel()
    @variable(model, x[1:4] >= 0.0, Int)
    objective!(model, 1, :Min, x[1] + x[2] + x[3] + x[4])
    objective!(model, 2, :Max, x[1] + 2x[2] + 3x[3] + 4x[4])
    @constraint(model, x[1] + x[2] + x[3] + x[4] <= 3)
    
    @time solutions = msea(model, fpbh=60.0, mdls=0, threads=1, message=true, turn_off_cplex_heur=false, num=1, ϵ=0.99, deterministic_exploration=true, minimum_dim=true, operations=[3])
    
    nothing
end

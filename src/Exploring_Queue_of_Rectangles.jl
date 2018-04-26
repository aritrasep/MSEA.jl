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

include("PSM.jl")
include("ECM_Operations.jl")
include("ECM.jl")
include("BBM.jl")

#####################################################################
## Explore a Queue of Rectangles                                   ##
#####################################################################

@inbounds function explore_a_rectangle(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, current_rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64, approximation::Bool, message::Bool)
    @match operation begin
        1:2 => psm(instance, model, current_rect, feasible_solutions, operation, ϵ, message)
        3:8 => ecm(instance, model, current_rect, feasible_solutions, operation, ϵ, min_len, approximation, message)
        _ => bbm(instance, model, current_rect, feasible_solutions, operation, ϵ, min_len, approximation, message)
    end
end

@inbounds function explore_a_rectangle!(metric::Vector{Float64}, instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, current_rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operations::Vector{Int64}, ϵ::Float64, min_len::Float64, approximation::Bool, message::Bool)
    ind = indmin(metric)
    operation = operations[ind]
    t0 = time()
    top_rect, bottom_rect, tmp, ip_solved, cplex_time = @match operation begin
        1:2 => psm(instance, model, current_rect, feasible_solutions, operation, ϵ, message)
        _ => ecm(instance, model, current_rect, feasible_solutions, operation, ϵ, min_len, approximation, message)
    end
    t1 = time()
    metric[ind] = t1 - t0
    top_rect, bottom_rect, tmp, ip_solved, cplex_time
end

@inbounds function explore_queue_of_rectangles(instance::Union{BOBPInstance, BOIPInstance}, deterministic_exploration::Bool, turn_off_cplex_heur::Bool, rects_to_explore::Vector{boo_rect}, non_dom_sols::Vector{BOPSolution}, feasible_solutions::Vector{BOPSolution}, operations::Vector{Int64}, ϵ::Float64, minimum_dim::Bool, approximation::Bool, timelimit::Float64, message::Bool, log_file_name::Union{String, Void})
    t0 = time()
    if message
        println("---------------------------------------------------------")
        @match deterministic_exploration begin
            true => println("Started exploring queues of rectangles deterministically\n")
            _ => println("Started exploring queues of rectangles stochastically\n")
        end
    end
    
    model = cplex_model(instance, 1, log_file_name)
    if turn_off_cplex_heur
        CPLEX.set_param!(model.env, "CPX_PARAM_HEURFREQ", -1)
        CPLEX.set_param!(model.env, "CPX_PARAM_RINSHEUR", -1)
        CPLEX.set_param!(model.env, "CPX_PARAM_FPHEUR", -1)
    end
    
    metric = zeros(length(operations))    
    current_operation = operations[1]
    
    min_len = min_len_for_a_ϵ(ϵ)
    choice_quantity_evaluator = minimum_dim ? minimum_dim_of_a_rect : area_of_a_rect
    choice_quantity = choice_quantity_evaluator(rects_to_explore)
    
    ip_solved = 0
    cplex_time = 0.0
    num_rects_explored = 0
    num_empty_rects_explored = 0
    
    while length(rects_to_explore) >= 1 && time() - t0 < timelimit
        ind = indmax(choice_quantity)
        current_rect = rects_to_explore[ind]
        deleteat!(choice_quantity, ind)
        deleteat!(rects_to_explore, ind)
        if length(current_rect.zT) == 0 || length(current_rect.zB) == 0 || current_rect.zB[1] - current_rect.zT[1] <= min_len || current_rect.zT[2] - current_rect.zB[2] <= min_len
            continue
        end
        if message
            print("Solving $current_rect using ")
        end
        inds = feasible_solutions_in_a_rect(current_rect, feasible_solutions)
        top_rect, bottom_rect, tmp, tmp2, tmp3 = @match deterministic_exploration begin
            true => explore_a_rectangle(instance, model, current_rect, feasible_solutions[inds], current_operation, ϵ, min_len, approximation, message)
            _ => explore_a_rectangle!(metric, instance, model, current_rect, feasible_solutions[inds], operations, ϵ, min_len, approximation, message)
        end
        ip_solved += tmp2
        cplex_time += tmp3
        if length(top_rect.zT) != 0 && length(top_rect.zB) != 0 && (top_rect.zB[1] - top_rect.zT[1] >= 2.0 * min_len || top_rect.zT[2] - top_rect.zB[2] >= 2.0 * min_len)
            push!(rects_to_explore, top_rect)
            push!(choice_quantity, choice_quantity_evaluator(rects_to_explore[end]))
        end
        if length(bottom_rect.zT) != 0 && length(bottom_rect.zB) != 0 && (bottom_rect.zB[1] - bottom_rect.zT[1] >= 2.0 * min_len || bottom_rect.zT[2] - bottom_rect.zB[2] >= 2.0 * min_len)
            push!(rects_to_explore, bottom_rect)
            push!(choice_quantity, choice_quantity_evaluator(rects_to_explore[end]))
        end
        empty_box = true
        for i in 1:length(tmp)
            if length(tmp[i].vars) > 0
                push!(non_dom_sols, tmp[i])
                push!(feasible_solutions, tmp[i])
                empty_box = false
            end
        end
        if empty_box
            if deterministic_exploration && length(operations) > 1
                deleteat!(operations, 1)
                current_operation = operations[1]
            end
            num_empty_rects_explored += 1
        end
        if message
            if empty_box
                print(" Empty Rectangle")
            end
            println()
        end
        num_rects_explored += 1
        if num_rects_explored % 25 == 0.0
            feasible_solutions = select_and_sort_non_dom_sols(feasible_solutions)
        end
    end
    if message
        @match deterministic_exploration begin
            true => println("\nFinished exploring queues of rectangles deterministically")
            _ => println("\nFinished exploring queues of rectangles stochastically")
        end
        println("---------------------------------------------------------")
    end
    select_and_sort_non_dom_sols(non_dom_sols), num_rects_explored, num_empty_rects_explored, rects_to_explore, ip_solved, cplex_time
end

@inbounds function explore_queue_of_rectangles(instance::Union{BOBPInstance, BOIPInstance}, turn_off_cplex_heur::Bool, rects_to_explore::Vector{boo_rect}, non_dom_sols::Vector{BOPSolution}, feasible_solutions::Vector{BOPSolution}, operations::Vector{Int64}, ϵ::Float64, deterministic_exploration::Bool, minimum_dim::Bool, approximation::Bool, timelimit::Float64, message::Bool, log_file_name::Union{String, Void}, threads::Int64)
    if threads == 1
        return explore_queue_of_rectangles(instance, deterministic_exploration, turn_off_cplex_heur, rects_to_explore, non_dom_sols, feasible_solutions, operations, ϵ, minimum_dim, approximation, timelimit, message, log_file_name)
    end
    
    procs_ = setdiff(procs(), myid())[1:threads]
    data = Vector{Any}(threads)
    @sync begin
        for i in 1:length(rects_to_explore)
            @async begin
                data[i] = remotecall_fetch(explore_queue_of_rectangles, procs_[i], instance, deterministic_exploration, turn_off_cplex_heur, [rects_to_explore[i]], non_dom_sols, feasible_solutions, operations, ϵ, minimum_dim, approximation, timelimit, message, log_file_name)
            end
        end
    end
    
    non_dom_sols = BOPSolution[]
    num_rects_explored = 0
    num_empty_rects_explored = 0
    rects_to_explore = boo_rect[]
    ip_solved = 0
    cplex_time = 0.0
    
    for i in 1:threads
        try
            push!(non_dom_sols, data[i][1]...)
            num_rects_explored += data[i][2]
            num_empty_rects_explored += data[i][3]
            push!(rects_to_explore, data[i][4]...)
            ip_solved += data[i][5]
            cplex_time = maximum([cplex_time, data[i][6]])
        catch
            break
        end
    end
    select_and_sort_non_dom_sols(non_dom_sols), num_rects_explored, num_empty_rects_explored, rects_to_explore, ip_solved, cplex_time
end

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

#####################################################################
### Decomposing a Rectangle into Smaller Rectangles               ###
#####################################################################

@inbounds function decomposing_a_rectangle_into_smaller_rectangles(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, num::Int64, cutting_direction::Int64, feasible_solutions::Vector{BOPSolution}, ϵ::Float64, message::Bool)
    if message
        print("Decomposing a Rectangle into $num smaller rectangles using ")
        @match cutting_direction begin
        	1 => println("Nadir point cuts")
        	2 => println("Vertical cuts")
        	3 => println("Horizontal cuts")
        	4 => println("Ideal point cuts")
        end
    end
    cplex_time = 0.0
    CPLEX.set_obj!(model, instance.c1 + instance.c2)
    non_dom_sols = BOPSolution[]
    for i in 1:num-1
    	if cutting_direction == 1
    		slope = tan((convert(Float64, i) * pi) / (convert(Float64, 2num)))
    		CPLEX.add_constr!(model, instance.c2 - slope * instance.c1, '<', rect.zT[2] - slope * rect.zB[1])
    		CPLEX.set_obj!(model, instance.c1)
    		CPLEX.set_warm_start!(model, feasible_solutions[2].vars, CPLEX.CPX_MIPSTART_NOCHECK)
    	end
    	if cutting_direction == 2
    		CPLEX.add_constr!(model, instance.c1, '<', rect.zT[1] + convert(Float64, i) * ( (rect.zB[1] - rect.zT[1]) / num ) )
    		CPLEX.set_obj!(model, instance.c2)
    		CPLEX.set_warm_start!(model, feasible_solutions[1].vars, CPLEX.CPX_MIPSTART_NOCHECK)
    	end
    	if cutting_direction == 3
    		CPLEX.add_constr!(model, instance.c2, '<', rect.zB[2] + convert(Float64, i) * ( (rect.zT[2] - rect.zB[2]) / num ) )
    		CPLEX.set_obj!(model, instance.c1)
    		CPLEX.set_warm_start!(model, feasible_solutions[2].vars, CPLEX.CPX_MIPSTART_NOCHECK)
    	end
    	if cutting_direction == 4
    		slope = tan((convert(Float64, num - i) * pi) / (convert(Float64, 2num)))
    		CPLEX.add_constr!(model, instance.c2 - slope * instance.c1, '<', rect.zB[2] - slope * rect.zT[1])
    		CPLEX.set_obj!(model, instance.c1)
    		CPLEX.set_warm_start!(model, feasible_solutions[2].vars, CPLEX.CPX_MIPSTART_NOCHECK)
    	end
        
        t0 = time()
        CPLEX.optimize!(model)
        cplex_time += time() - t0
        
        tmp = BOPSolution(vars=round.(CPLEX.get_solution(model)))
        compute_objective_function_value!(tmp, instance)
        del_constrs!(model, CPLEX.num_constr(model))
        del_all_warm_starts!(model)
        tmp1, tmp2, tmp3, tmp4, tmp5 = psm_on_a_feasible_solution(instance, model, rect, [tmp], ϵ)
        push!(non_dom_sols, tmp3[1])
        
        cplex_time += tmp5
    end
    non_dom_sols, 2(num-1), cplex_time
end

#####################################################################
### Lexicographic Method                                          ###
#####################################################################

@inbounds function lex_min(c1::Vector{Float64}, c2::Vector{Float64}, model::CPLEX.Model, feasible_solutions::Vector{BOPSolution})
    tmp = Float64[]
    cplex_time = 0.0
    for i in 1:2
        if i == 1
            CPLEX.set_obj!(model, c1)
            if length(feasible_solutions) >= 1
                CPLEX.set_warm_start!(model, feasible_solutions[1].vars, CPLEX.CPX_MIPSTART_NOCHECK)
            end
        else
            CPLEX.add_constr!(model, c1, '<', CPLEX.get_objval(model))
            CPLEX.set_obj!(model, c2)
            CPLEX.set_warm_start!(model, round.(tmp), CPLEX.CPX_MIPSTART_NOCHECK)
        end

        t0 = time()
        CPLEX.optimize!(model)
        cplex_time += time() - t0

        del_all_warm_starts!(model)
        if CPLEX.get_status_code(model) == 101
            tmp = round.(CPLEX.get_solution(model))
        else
            return BOPSolution(), cplex_time
        end
    end
    #CPLEX.set_param!(model.env, 2058, CPLEX.CPX_MIPEMPHASIS_BALANCED)
    tmp = round.(CPLEX.get_solution(model))
    del_constrs!(model, CPLEX.num_constr(model))
    return BOPSolution(vars=tmp), cplex_time
end

@inbounds function lex_min(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, feasible_solutions::Vector{BOPSolution})
    non_dom_sols = BOPSolution[]
    cplex_time = 0.0
    tmp = BOPSolution()
    for i in 1:2
        tmp, tmp1 = @match i begin
            1 => lex_min(instance.c1, instance.c2, model, feasible_solutions)
            2 => lex_min(instance.c2, instance.c1, model, feasible_solutions)
        end
        cplex_time += tmp1
        if length(tmp.vars) == 0
            continue
        else
            compute_objective_function_value!(tmp, instance)
            push!(non_dom_sols, tmp)
        end
    end
    sort_non_dom_sols(non_dom_sols), cplex_time
end

###############################################################################
## Initial Start                                                             ##
###############################################################################

@inbounds function initial_start(instance::Union{BOBPInstance, BOIPInstance}, message::Bool, turn_off_cplex_heur::Bool, feasible_solutions::Vector{BOPSolution}, num::Int64, cutting_direction::Int64, ϵ::Float64)

    if message
        println("---------------------------------------------------------")
        println("Finding Corner Points using Lex Min")
    end
    
    model = cplex_model(instance, 1)
    if turn_off_cplex_heur
        CPLEX.set_param!(model.env, "CPX_PARAM_HEURFREQ", -1)
        CPLEX.set_param!(model.env, "CPX_PARAM_RINSHEUR", -1)
        CPLEX.set_param!(model.env, "CPX_PARAM_FPHEUR", -1)
    end
    
    non_dom_sols, cplex_time = lex_min(instance, model, feasible_solutions)
    rects_to_explore = boo_rect[]
    ip_solved = 4
    
    if length(non_dom_sols) == 2
        rect = boo_rect()
        rect.zT = [non_dom_sols[1].obj_val1, non_dom_sols[1].obj_val2]
        rect.zB = [non_dom_sols[end].obj_val1, non_dom_sols[end].obj_val2]
        if num > 1
            tmp1, tmp2, tmp3 = decomposing_a_rectangle_into_smaller_rectangles(instance, model, rect, num, cutting_direction, non_dom_sols, ϵ, message)
            non_dom_sols = select_and_sort_non_dom_sols([non_dom_sols..., tmp1...])
            for i in 1:length(non_dom_sols)-1
                rect = boo_rect()
                rect.zT = [non_dom_sols[i].obj_val1, non_dom_sols[i].obj_val2]
                rect.zB = [non_dom_sols[i+1].obj_val1, non_dom_sols[i+1].obj_val2]
                push!(rects_to_explore, rect)
            end
            ip_solved += tmp2
            cplex_time += tmp3
        else
            push!(rects_to_explore, rect)
        end
    end
    
    if message
        println("---------------------------------------------------------")
    end

    non_dom_sols, select_and_sort_non_dom_sols([non_dom_sols..., feasible_solutions...]), rects_to_explore, ip_solved, cplex_time
end

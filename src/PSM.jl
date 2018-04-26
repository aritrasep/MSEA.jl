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
## Perpendicular Search Method                                     ##
#####################################################################

@inbounds function psm_on_a_feasible_solution(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, ϵ::Float64)
    if length(feasible_solutions) >= 1
        ind = best_feasible_solution_for_psm(instance, rect, feasible_solutions, ϵ)
        if ind != 0
            CPLEX.set_obj!(model, instance.c1 + instance.c2)
            CPLEX.add_constr!(model, instance.c1, '<', feasible_solutions[ind].obj_val1)
            CPLEX.add_constr!(model, instance.c2, '<', feasible_solutions[ind].obj_val2)
            CPLEX.set_warm_start!(model, feasible_solutions[ind].vars, CPLEX.CPX_MIPSTART_NOCHECK)
            
            t0 = time()
            CPLEX.optimize!(model)
            t1 = time()
            
            tmp = BOPSolution(vars=round.(CPLEX.get_solution(model)))
            compute_objective_function_value!(tmp, instance)
            del_constrs!(model, Cint(length(instance.cons_lb)+1), CPLEX.num_constr(model))
            del_all_warm_starts!(model)
            top_rect, bottom_rect = copy(rect), copy(rect)
            top_rect.zB = [tmp.obj_val1, tmp.obj_val2]
            bottom_rect.zT = [tmp.obj_val1, tmp.obj_val2]
            ip_solved = 1
        else
            top_rect = copy(rect)
            bottom_rect = boo_rect()
            tmp = BOPSolution()
            ip_solved = 0
        end
    end
    top_rect, bottom_rect, [tmp], ip_solved, t1 - t0
end

@inbounds function psm(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, ϵ::Float64)
    CPLEX.set_obj!(model, instance.c1 + instance.c2)
    CPLEX.add_constr!(model, instance.c1, '<', rect.zB[1] - ϵ)
    CPLEX.add_constr!(model, instance.c2, '<', rect.zT[2] - ϵ)
    if length(feasible_solutions) >= 1
        ind = best_feasible_solution_for_psm(instance, rect, feasible_solutions, ϵ)
        if ind != 0
            CPLEX.set_warm_start!(model, feasible_solutions[ind].vars, CPLEX.CPX_MIPSTART_NOCHECK)
        end
    end
    
    t0 = time()
    CPLEX.optimize!(model)
    t1 = time()
    
    if CPLEX.get_status_code(model) == 101
        tmp = BOPSolution(vars=round.(CPLEX.get_solution(model)))
        compute_objective_function_value!(tmp, instance)
        top_rect, bottom_rect = copy(rect), copy(rect)
        top_rect.zB = [tmp.obj_val1, tmp.obj_val2]
        bottom_rect.zT = [tmp.obj_val1, tmp.obj_val2]
    else
        tmp = BOPSolution()
        top_rect, bottom_rect = boo_rect(), boo_rect()
    end
    del_constrs!(model, Cint(length(instance.cons_lb)+1), CPLEX.num_constr(model))
    del_all_warm_starts!(model)
    top_rect, bottom_rect, [tmp], 1, t1 - t0
end

@inbounds function psm(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, message::Bool)
    feasible_solutions = select_non_dom_sols(feasible_solutions)
    if length(feasible_solutions) <= 2
        if operation == 2 && typeof(instance) == BOBPInstance
            if message
                print("BINS + ")
            end
            tmp, cplex_time_1 = bins(instance, model, rect, feasible_solutions, ϵ)
            if length(tmp.vars) != 0
                if message
                    print("PSM on a Feasible Solution")
                end
                top_rect, bottom_rect, tmp2, ip_solved, cplex_time_2 = psm_on_a_feasible_solution(instance, model, rect, [tmp], ϵ)
                return top_rect, bottom_rect, tmp2, ip_solved + 1, cplex_time_1 + cplex_time_2
            end
            ip_solved_ = 1
        else
            cplex_time_1 = 0.0
            ip_solved_ = 0
        end
        if message
            print("PSM")
        end
        top_rect, bottom_rect, tmp2, ip_solved, cplex_time_3 = psm(instance, model, rect, feasible_solutions, ϵ)
        return top_rect, bottom_rect, tmp2, ip_solved + ip_solved_, cplex_time_1 + cplex_time_3
    else
        if message
            print("PSM on a Feasible Solution")
        end
        psm_on_a_feasible_solution(instance, model, rect, feasible_solutions, ϵ)
    end
end

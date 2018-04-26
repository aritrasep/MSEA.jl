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
## ϵ Constraint Method                                             ##
#####################################################################

@inbounds function ecm(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64, approximation::Bool, message::Bool)
    feasible_solutions = select_non_dom_sols(feasible_solutions)
    if length(feasible_solutions) <= 2 || !approximation
        if message
            @match operation begin
                3 => print("ECM TD LM")
                4 => print("ECM TD LM2")
                5 => print("ECM TD AO")
                6 => print("ECM RL LM")
                7 => print("ECM RL LM2")
                8 => print("ECM RL AO")
            end
        end
        @match operation begin
            3:5 => udecm_td(instance, model, rect, feasible_solutions, operation, ϵ, min_len)
            6:8 => udecm_rl(instance, model, rect, feasible_solutions, operation, ϵ, min_len) 
        end
    else
        if message
            @match operation begin
                3 => print("ECM TD LM on a Feasible Solution")
                4 => print("ECM TD LM2 on a Feasible Solution")
                5 => print("ECM TD AO on a Feasible Solution")
                6 => print("ECM RL LM on a Feasible Solution")
                7 => print("ECM RL LM2 on a Feasible Solution")
                8 => print("ECM RL AO on a Feasible Solution")
            end
        end
        @match operation begin
            3:5 => udecm_td_on_a_feasible_solution(instance, model, rect, feasible_solutions, operation, ϵ, min_len)
            6:8 => udecm_rl_on_a_feasible_solution(instance, model, rect, feasible_solutions, operation, ϵ, min_len)
        end
    end
end

#####################################################################
### Top Down Cut                                                  ###
#####################################################################

@inbounds function udecm_td(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64)
    solver, mip_emphasis = @match operation begin
        3 => explore_rectangle_td_using_lex_min, false
        4 => explore_rectangle_td_using_lex_min, true
        5 => explore_rectangle_td_using_augmented_operation, false
    end
    ind = best_feasible_solution_for_udecm_td(instance, rect.zT[2] - ϵ, feasible_solutions)
    top_rect, bottom_rect, tmp, ip_solved, cplex_time = solver(instance, model, rect, rect.zT[2] - ϵ, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    if length(tmp.vars) == 0
        bottom_rect = boo_rect()
    end
    boo_rect(), bottom_rect, [tmp], ip_solved, cplex_time
end

#####################################################################
### Top Down Cut on a Feasible Solution                           ###
#####################################################################

@inbounds function udecm_td_on_a_feasible_solution(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64)
    solver, mip_emphasis = @match operation begin
        3 => explore_rectangle_td_using_lex_min, false
        4 => explore_rectangle_td_using_lex_min, true
        5 => explore_rectangle_td_using_augmented_operation, false
    end
    ind = best_feasible_solution_for_udecm_td(instance, rect.zT[2] - ϵ, feasible_solutions)
    top_rect, bottom_rect, tmp, ip_solved, cplex_time = solver(instance, model, rect, feasible_solutions[ind].obj_val2, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    top_rect, bottom_rect, [tmp], ip_solved, cplex_time
end

#####################################################################
### Right Left Cut                                                ###
#####################################################################

@inbounds function udecm_rl(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64)
    solver, mip_emphasis = @match operation begin
        6 => explore_rectangle_rl_using_lex_min, false
        7 => explore_rectangle_rl_using_lex_min, true
        8 => explore_rectangle_rl_using_augmented_operation, false
    end
    ind = best_feasible_solution_for_udecm_rl(instance, rect.zB[1] - ϵ, feasible_solutions)
    top_rect, bottom_rect, tmp, ip_solved, cplex_time = solver(instance, model, rect, rect.zB[1] - ϵ, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    if length(tmp.vars) == 0
        top_rect = boo_rect()
    end
    top_rect, boo_rect(), [tmp], ip_solved, cplex_time
end

#####################################################################
### Right Left Cut on a Feasible Solution                         ###
#####################################################################

@inbounds function udecm_rl_on_a_feasible_solution(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64)
    solver, mip_emphasis = @match operation begin
        6 => explore_rectangle_rl_using_lex_min, false
        7 => explore_rectangle_rl_using_lex_min, true
        8 => explore_rectangle_rl_using_augmented_operation, false
    end
    ind = best_feasible_solution_for_udecm_rl(instance, rect.zB[1] - ϵ, feasible_solutions)
    top_rect, bottom_rect, tmp, ip_solved, cplex_time = solver(instance, model, rect, feasible_solutions[ind].obj_val1, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    top_rect, bottom_rect, [tmp], ip_solved, cplex_time
end

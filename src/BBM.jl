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
## Balanced Box Method (Double ϵ Constraint Method)                ##
#####################################################################

@inbounds function bbm(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64, approximation::Bool, message::Bool)
    feasible_solutions = select_non_dom_sols(feasible_solutions)
    if length(feasible_solutions) <= 2 || !approximation
        if message
            @match operation begin
                9 => print("BBM TDRL LM")
                10 => print("BBM TDRL LM2")
                11 => print("BBM TDRL AO")
                12 => print("BBM RLTD LM")
                13 => print("BBM RLTD LM2")
                14 => print("BBM RLTD AO")
            end
        end
        @match operation begin
            9:11 => bbm_tdrl(instance, model, rect, feasible_solutions, operation, ϵ, min_len)
            12:14 => bbm_rltd(instance, model, rect, feasible_solutions, operation, ϵ, min_len)
        end
    else
        if message
            @match operation begin
                9 => print("BBM TDRL LM on a Feasible Solution")
                10 => print("BBM TDRL LM2 on a Feasible Solution")
                11 => print("BBM TDRL AO on a Feasible Solution")
                12 => print("BBM RLTD LM on a Feasible Solution")
                13 => print("BBM RLTD LM2 on a Feasible Solution")
                14 => print("BBM RLTD AO on a Feasible Solution")
            end
        end
        @match operation begin
            9:11 => bbm_tdrl_on_a_feasible_solution(instance, model, rect, feasible_solutions, operation, ϵ, min_len)
            12:14 => bbm_rltd_on_a_feasible_solution(instance, model, rect, feasible_solutions, operation, ϵ, min_len)
        end
    end
end

#####################################################################
### Top Down -> Right Left                                        ###
#####################################################################

@inbounds function bbm_tdrl(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64)
    solver1, solver2, mip_emphasis = @match operation begin
        9 => explore_rectangle_td_using_lex_min, explore_rectangle_rl_using_lex_min, false
        10 => explore_rectangle_td_using_lex_min, explore_rectangle_rl_using_lex_min, true
        11 => explore_rectangle_td_using_augmented_operation, explore_rectangle_rl_using_augmented_operation, false
    end
    td_cut = (rect.zT[2] + rect.zB[2])/2.0
    rl_cut = rect.zB[1] - ϵ
    ind = best_feasible_solution_for_udecm_td(instance, td_cut, feasible_solutions)
    top_rect_1, bottom_rect_1, tmp_1, ip_solved_1, cplex_time_1 = solver1(instance, model, rect, td_cut, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    if length(tmp_1.vars) != 0
        rl_cut = tmp_1.obj_val1 - ϵ
    else
        bottom_rect_1 = boo_rect()
    end
    if length(top_rect_1.zT) == 0 || length(top_rect_1.zB) == 0 || top_rect_1.zB[1] - top_rect_1.zT[1] <= min_len || top_rect_1.zT[2] - top_rect_1.zB[2] <= min_len
        return boo_rect(), bottom_rect_1, [tmp_1], ip_solved_1, cplex_time_1
    end
    ind = best_feasible_solution_for_udecm_rl(instance, rl_cut, feasible_solutions)
    top_rect_2, bottom_rect_2, tmp_2, ip_solved_2, cplex_time_2 = solver2(instance, model, top_rect_1, rl_cut, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    if length(tmp_2.vars) == 0
        top_rect_2 = boo_rect()
    end
    top_rect_2, bottom_rect_1, [tmp_2, tmp_1], ip_solved_1 + ip_solved_2, cplex_time_1 + cplex_time_2
end

@inbounds function bbm_tdrl_on_a_feasible_solution(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64)
    solver1, solver2, mip_emphasis = @match operation begin
        9 => explore_rectangle_td_using_lex_min, explore_rectangle_rl_using_lex_min, false
        10 => explore_rectangle_td_using_lex_min, explore_rectangle_rl_using_lex_min, true
        11 => explore_rectangle_td_using_augmented_operation, explore_rectangle_rl_using_augmented_operation, false
    end
    td_cut = rect.zT[2] - ϵ
    rl_cut = rect.zB[1] - ϵ
    ind = best_feasible_solution_for_udecm_rl(instance, rl_cut, feasible_solutions)
    top_rect_1, bottom_rect_1, tmp_1, ip_solved_1, cplex_time_1 = solver1(instance, model, rect, feasible_solutions[ind].obj_val2, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    if length(tmp_1.vars) != 0
        rl_cut = tmp_1.obj_val1 - ϵ
    else
        bottom_rect_1 = boo_rect()
    end
    if length(top_rect_1.zT) == 0 || length(top_rect_1.zB) == 0 || top_rect_1.zB[1] - top_rect_1.zT[1] <= min_len || top_rect_1.zT[2] - top_rect_1.zB[2] <= min_len
        return boo_rect(), bottom_rect_1, [tmp_1], ip_solved_1, cplex_time_1
    end
    ind = best_feasible_solution_for_udecm_rl(instance, rl_cut, feasible_solutions)
    top_rect_2, bottom_rect_2, tmp_2, ip_solved_2, cplex_time_2 = solver2(instance, model, top_rect_1, rl_cut, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    if length(tmp_2.vars) == 0
        top_rect_2 = boo_rect()
    end
    top_rect_2, bottom_rect_1, [tmp_2, tmp_1], ip_solved_1 + ip_solved_2, cplex_time_1 + cplex_time_2
end

#####################################################################
### Right Left -> Top Down                                        ###
#####################################################################

@inbounds function bbm_rltd(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64)
    solver1, solver2, mip_emphasis = @match operation begin
        12 => explore_rectangle_rl_using_lex_min, explore_rectangle_td_using_lex_min, false
        13 => explore_rectangle_rl_using_lex_min, explore_rectangle_td_using_lex_min, true
        14 => explore_rectangle_rl_using_augmented_operation, explore_rectangle_td_using_augmented_operation, false
    end
    rl_cut = (rect.zT[1] + rect.zB[1])/2.0
    td_cut = rect.zT[2] - ϵ
    ind = best_feasible_solution_for_udecm_rl(instance, rl_cut, feasible_solutions)
    top_rect_1, bottom_rect_1, tmp_1, ip_solved_1, cplex_time_1 = solver1(instance, model, rect, rl_cut, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    if length(tmp_1.vars) != 0
        td_cut = tmp_1.obj_val2 - ϵ
    else
        top_rect_1 = boo_rect()
    end
    if length(bottom_rect_1.zT) == 0 || length(bottom_rect_1.zB) == 0 || bottom_rect_1.zB[1] - bottom_rect_1.zT[1] <= min_len || bottom_rect_1.zT[2] - bottom_rect_1.zB[2] <= min_len
        return top_rect_1, boo_rect(), [tmp_1], ip_solved_1, cplex_time_1
    end
    ind = best_feasible_solution_for_udecm_td(instance, td_cut, feasible_solutions)
    top_rect_2, bottom_rect_2, tmp_2, ip_solved_2, cplex_time_2 = solver2(instance, model, bottom_rect_1, td_cut, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    if length(tmp_2.vars) == 0
        bottom_rect_2 = boo_rect()
    end
    top_rect_1, bottom_rect_2, [tmp_1, tmp_2], ip_solved_1 + ip_solved_2, cplex_time_1 + cplex_time_2
end

@inbounds function bbm_rltd_on_a_feasible_solution(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, operation::Int64, ϵ::Float64, min_len::Float64)
    solver1, solver2, mip_emphasis = @match operation begin
        12 => explore_rectangle_rl_using_lex_min, explore_rectangle_td_using_lex_min, false
        13 => explore_rectangle_rl_using_lex_min, explore_rectangle_td_using_lex_min, true
        14 => explore_rectangle_rl_using_augmented_operation, explore_rectangle_td_using_augmented_operation, false
    end
    td_cut = rect.zT[2] - ϵ
    rl_cut = rect.zB[1] - ϵ
    ind = best_feasible_solution_for_udecm_td(instance, td_cut, feasible_solutions)
    top_rect_1, bottom_rect_1, tmp_1, ip_solved_1, cplex_time_1 = solver1(instance, model, rect, feasible_solutions[ind].obj_val1, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    if length(tmp_1.vars) != 0
        td_cut = tmp_1.obj_val2 - ϵ
    else
        top_rect_1 = boo_rect()
    end
    if length(bottom_rect_1.zT) == 0 || length(bottom_rect_1.zB) == 0 || bottom_rect_1.zB[1] - bottom_rect_1.zT[1] <= min_len || bottom_rect_1.zT[2] - bottom_rect_1.zB[2] <= min_len
        return top_rect_1, boo_rect(), [tmp_1], ip_solved_1, cplex_time_1
    end
    ind = best_feasible_solution_for_udecm_td(instance, td_cut, feasible_solutions)
    top_rect_2, bottom_rect_2, tmp_2, ip_solved_2, cplex_time_2 = solver2(instance, model, bottom_rect_1, td_cut, feasible_solutions[ind], ϵ, min_len, mip_emphasis)
    if length(tmp_2.vars) == 0
        bottom_rect_2 = boo_rect()
    end
    top_rect_1, bottom_rect_2, [tmp_1, tmp_2], ip_solved_1 + ip_solved_2, cplex_time_1 + cplex_time_2
end

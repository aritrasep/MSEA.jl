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
# Exploring a Rectangle                                             #
#####################################################################

#####################################################################
## Using Lex Min                                                   ##
#####################################################################

#####################################################################
### Top->Down (TD)                                                ###
#####################################################################

@inbounds function explore_rectangle_td_using_lex_min(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, amount_of_cut::Float64, feasible_solution::BOPSolution, ϵ::Float64, min_len::Float64, mip_emphasis::Bool)
    top_rect, bottom_rect = copy(rect), copy(rect)
    CPLEX.add_constr!(model, instance.c2, '<', amount_of_cut)
    CPLEX.set_obj!(model, instance.c1)
    CPLEX.set_warm_start!(model, feasible_solution.vars, CPLEX.CPX_MIPSTART_NOCHECK)
    
    t0 = time()
    CPLEX.optimize!(model)
    t1 = time()
    
    del_all_warm_starts!(model)
    if CPLEX.get_objval(model) == rect.zB[1]
        del_constrs!(model, CPLEX.num_constr(model))
        top_rect, boo_rect(), BOPSolution(), 1, t1 - t0
    else
        tmp = round.(CPLEX.get_solution(model))
        if mip_emphasis
            CPLEX.set_param!(model.env, 2058, CPLEX.CPX_MIPEMPHASIS_OPTIMALITY)
        end
        amount_of_cut = CPLEX.get_objval(model)
        CPLEX.add_constr!(model, instance.c1, '<', amount_of_cut)
        del_constrs!(model, CPLEX.num_constr(model)-1)
        CPLEX.set_obj!(model, instance.c2)
        CPLEX.set_warm_start!(model, tmp, CPLEX.CPX_MIPSTART_NOCHECK)
        
        t2 = time()
        CPLEX.optimize!(model)
        t3 = time()
        
        del_all_warm_starts!(model)
        if mip_emphasis
            CPLEX.set_param!(model.env, 2058, CPLEX.CPX_MIPEMPHASIS_BALANCED)
        end
        tmp2 = BOPSolution(vars=round.(CPLEX.get_solution(model)))
        compute_objective_function_value!(tmp2, instance)
        del_constrs!(model, CPLEX.num_constr(model))
        top_rect.zB = [tmp2.obj_val1, tmp2.obj_val2]
        bottom_rect.zT = [tmp2.obj_val1, tmp2.obj_val2]
        top_rect, bottom_rect, tmp2, 2, t1 + t3 - t0 - t2
    end
end

#####################################################################
### Right->Left (RL)                                              ###
#####################################################################

@inbounds function explore_rectangle_rl_using_lex_min(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, amount_of_cut::Float64, feasible_solution::BOPSolution, ϵ::Float64, min_len::Float64, mip_emphasis::Bool)
    top_rect, bottom_rect = copy(rect), copy(rect)
    CPLEX.add_constr!(model, instance.c1, '<', amount_of_cut)
    CPLEX.set_obj!(model, instance.c2)
    CPLEX.set_warm_start!(model, feasible_solution.vars, CPLEX.CPX_MIPSTART_NOCHECK)
    
    t0 = time()
    CPLEX.optimize!(model)
    t1 = time()
    
    del_all_warm_starts!(model)
    if CPLEX.get_objval(model) == rect.zT[2]
        del_constrs!(model, CPLEX.num_constr(model))
        boo_rect(), bottom_rect, BOPSolution(), 1, t1 - t0
    else
        tmp = round.(CPLEX.get_solution(model))
        if mip_emphasis
            CPLEX.set_param!(model.env, 2058, CPLEX.CPX_MIPEMPHASIS_OPTIMALITY)
        end
        amount_of_cut = CPLEX.get_objval(model)
        CPLEX.add_constr!(model, instance.c2, '<', amount_of_cut)
        del_constrs!(model, CPLEX.num_constr(model)-1)
        CPLEX.set_obj!(model, instance.c1)
        CPLEX.set_warm_start!(model, tmp, CPLEX.CPX_MIPSTART_NOCHECK)
        
        t2 = time()
        CPLEX.optimize!(model)
        t3 = time()
        
        del_all_warm_starts!(model)
        if mip_emphasis
            CPLEX.set_param!(model.env, 2058, CPLEX.CPX_MIPEMPHASIS_BALANCED)
        end
        tmp2 = BOPSolution(vars=round.(CPLEX.get_solution(model)))
        compute_objective_function_value!(tmp2, instance)
        del_constrs!(model, CPLEX.num_constr(model))
        top_rect.zB = [tmp2.obj_val1, tmp2.obj_val2]
        bottom_rect.zT = [tmp2.obj_val1, tmp2.obj_val2]
        top_rect, bottom_rect, tmp2, 2, t1 + t3 - t0 - t2
    end
end

#####################################################################
## Using Augmented Operation                                       ##
#####################################################################

#####################################################################
### Top->Down (TD)                                                ###
#####################################################################

@inbounds function explore_rectangle_td_using_augmented_operation(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, amount_of_cut::Float64, feasible_solution::BOPSolution, ϵ::Float64, min_len::Float64, mip_emphasis::Bool)
    top_rect, bottom_rect = copy(rect), copy(rect)
    CPLEX.set_obj!(model, instance.c1 + (1.0 / (amount_of_cut - rect.zB[2] + ϵ + min_len)) * instance.c2)
    CPLEX.add_constr!(model, instance.c2, '<', amount_of_cut)	
    CPLEX.set_warm_start!(model, feasible_solution.vars, CPLEX.CPX_MIPSTART_NOCHECK)
    
    t0 = time()
    CPLEX.optimize!(model)
    t1 = time()
    
    del_all_warm_starts!(model)
    tmp = BOPSolution(vars=round.(CPLEX.get_solution(model)))
    compute_objective_function_value!(tmp, instance)
    del_constrs!(model, CPLEX.num_constr(model))
    top_rect.zB = [tmp.obj_val1, tmp.obj_val2]
    bottom_rect.zT = [tmp.obj_val1, tmp.obj_val2]
    if tmp.obj_val1 >= bottom_rect.zB[1] || tmp.obj_val2 <= bottom_rect.zB[2]
        bottom_rect = boo_rect()
        tmp = BOPSolution()
    end
    top_rect, bottom_rect, tmp, 1, t1 - t0
end

#####################################################################
### Right->Left (RL)                                              ###
#####################################################################

@inbounds function explore_rectangle_rl_using_augmented_operation(instance::Union{BOBPInstance, BOIPInstance}, model::CPLEX.Model, rect::boo_rect, amount_of_cut::Float64, feasible_solution::BOPSolution, ϵ::Float64, min_len::Float64, mip_emphasis::Bool)
    top_rect, bottom_rect = copy(rect), copy(rect)
    CPLEX.set_obj!(model, (1.0 / (amount_of_cut - rect.zT[1] + ϵ + min_len)) * instance.c1 + instance.c2)
    CPLEX.add_constr!(model, instance.c1, '<', amount_of_cut)
    CPLEX.set_warm_start!(model, feasible_solution.vars, CPLEX.CPX_MIPSTART_NOCHECK)
      
    t0 = time()
    CPLEX.optimize!(model)
    t1 = time()
    
    del_all_warm_starts!(model)
    tmp = BOPSolution(vars=round.(CPLEX.get_solution(model)))
    compute_objective_function_value!(tmp, instance)
    del_constrs!(model, CPLEX.num_constr(model))
    top_rect.zB = [tmp.obj_val1, tmp.obj_val2]
    bottom_rect.zT = [tmp.obj_val1, tmp.obj_val2]
    if tmp.obj_val1 <= top_rect.zT[1] || tmp.obj_val2 >= top_rect.zT[2]
        top_rect = boo_rect()
        tmp = BOPSolution()
    end
    top_rect, bottom_rect, tmp, 1, t1 - t0
end

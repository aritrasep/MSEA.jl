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
# Computing Areas and Minimum Dimensions of a Rectangle             #
#####################################################################

@inbounds function area_of_a_rect(rect::boo_rect)
    (rect.zT[2] - rect.zB[2]) * (rect.zB[1] - rect.zT[1])
end

@inbounds function area_of_a_rect(rects::Vector{boo_rect})
    areas = Float64[]
    for i in 1:length(rects)
        push!(areas, area_of_a_rect(rects[i]))
    end
    areas
end

@inbounds function minimum_dim_of_a_rect(rect::boo_rect)
    minimum([rect.zT[2] - rect.zB[2], rect.zB[1] - rect.zT[1]])
end

@inbounds function minimum_dim_of_a_rect(rects::Vector{boo_rect})
    min_dims = Float64[]
    for i in 1:length(rects)
        push!(min_dims, minimum_dim_of_a_rect(rects[i]))
    end
    min_dims
end

#####################################################################
## Computing Indices of Best Feasibile Points inside a Rectangle   ##
#####################################################################

@inbounds function feasible_solutions_in_a_rect(rect::boo_rect, feasible_solutions::Vector{BOPSolution})
    inds = Int64[]
    for i in 1:length(feasible_solutions)
        if feasible_solutions[i].obj_val1 >= rect.zT[1] && feasible_solutions[i].obj_val2 <= rect.zT[2] && feasible_solutions[i].obj_val1 <= rect.zB[1] && feasible_solutions[i].obj_val2 >= rect.zB[2]
            push!(inds, i)
        end
    end
    inds
end

@inbounds function best_feasible_solution_for_psm(instance::Union{BOBPInstance, BOIPInstance}, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, ϵ::Float64)
    best_ind = 0
    best_obj = Inf
    for i in 1:length(feasible_solutions)
        if feasible_solutions[i].obj_val1 <= rect.zB[1] - ϵ && feasible_solutions[i].obj_val2 <= rect.zT[2] - ϵ && feasible_solutions[i].obj_val1 + feasible_solutions[i].obj_val2 <= best_obj
            best_obj = feasible_solutions[i].obj_val1 + feasible_solutions[i].obj_val2
            best_ind = i
        end
    end
    best_ind
end

@inbounds function best_feasible_solution_for_udecm_td(instance::Union{BOBPInstance, BOIPInstance}, amount_of_cut::Float64, feasible_solutions::Vector{BOPSolution})
    best_ind = 0
    best_obj = Inf
    for i in 1:length(feasible_solutions)
        if feasible_solutions[i].obj_val2 <= amount_of_cut && feasible_solutions[i].obj_val1 <= best_obj
            best_obj = feasible_solutions[i].obj_val1
            best_ind = i
        end
    end
    best_ind
end

@inbounds function best_feasible_solution_for_udecm_rl(instance::Union{BOBPInstance, BOIPInstance}, amount_of_cut::Float64, feasible_solutions::Vector{BOPSolution})
    best_ind = 0
    best_obj = Inf
    for i in 1:length(feasible_solutions)
        if feasible_solutions[i].obj_val1 <= amount_of_cut && feasible_solutions[i].obj_val2 <= best_obj
            best_obj = feasible_solutions[i].obj_val2
            best_ind = i
        end
    end
    best_ind
end

#####################################################################
## Computing Minimum Length for an Epsilon                         ##
#####################################################################

@inbounds function min_len_for_a_ϵ(ϵ::Float64=0.99)
    multiplier = 1.0
    while round(ϵ*multiplier) != 1.0
        multiplier = multiplier * 10.0
    end
    1.0 / multiplier
end

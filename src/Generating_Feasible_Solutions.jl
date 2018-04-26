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

@inbounds function generating_feasible_solutions(instance::Union{BOBPInstance, BOIPInstance}, feasible_solutions::Vector{BOPSolution}, fpbh::Float64, mdls::Int64, threads::Int64, message::Bool)

    ###########################################################################
    # Feasible Solutions                                                      #
    ###########################################################################
    
    if length(feasible_solutions) >= 1
        feasible_solutions = check_feasibility(feasible_solutions, instance) # Extend for BOIPInstance
        compute_objective_function_value!(feasible_solutions, instance) # Extend for BOIPInstance
        if message
            println("---------------------------------------------------------")
            println("$(length(feasible_solutions)) feasible solutions has been provided by the User")
            println("---------------------------------------------------------")
        end
    end
    
    ###########################################################################
    ## FPBHCPLEX                                                             ##
    ###########################################################################
    
    if fpbh != 0.0
        tmp = @match fpbh > 0.0 begin
            true => fpbhcplex(instance, timelimit=fpbh, threads=threads)
            _ => fpbhcplex(instance, solution_polishing=false, timelimit=-1.0*fpbh, threads=threads)
        end
        if message
            println("---------------------------------------------------------")
            println("FPBHCPLEX has found $(length(tmp)) feasible solutions")
            println("---------------------------------------------------------")
        end
        feasible_solutions = select_and_sort_non_dom_sols([feasible_solutions..., tmp...])
    end
    
    ###########################################################################
    ## MDLS                                                                  ##
    ###########################################################################
    
    if mdls > 0
        try
            tmp = @match mdls begin
                1 => mdls_kp(instance)
                2 => mdls_bospp(instance)
            end
            if length(tmp) >= 1
                if message
                    println("---------------------------------------------------------")
                    println("MDLS has found $(length(tmp)) feasible solutions")
                    println("---------------------------------------------------------")
                end
                feasible_solutions = select_and_sort_non_dom_sols([feasible_solutions..., tmp...])
            end
        catch
            if message
                println("---------------------------------------------------------")
                println("MDLS is not suitable for this class of problem")
                println("---------------------------------------------------------")
            end
        end
    end
    
    if message
        println("---------------------------------------------------------")
        println("$(length(feasible_solutions)) feasible solutions are available")
        println("---------------------------------------------------------")
    end
    
    feasible_solutions
end

#####################################################################
## Binary Induced Neighborhood Search Method                       ##
#####################################################################

@inbounds function bins(instance::BOBPInstance, model::CPLEX.Model, rect::boo_rect, feasible_solutions::Vector{BOPSolution}, ϵ::Float64)
    lowerbound = zeros(length(instance.c1))
    upperbound = ones(length(instance.c1))
    for i in 1:length(instance.c1)
        if feasible_solutions[1].vars[i] == feasible_solutions[2].vars[i]
            if feasible_solutions[1].vars[i] == 0.0
                upperbound[i] = 0.0
            else
                lowerbound[i] = 1.0
            end
        end
    end
    CPLEX.set_varLB!(model, lowerbound)
    CPLEX.set_varUB!(model, upperbound)
    CPLEX.set_obj!(model, instance.c1 + instance.c2)
    CPLEX.add_constr!(model, instance.c1, '<', rect.zB[1] - ϵ)
    CPLEX.add_constr!(model, instance.c2, '<', rect.zT[2] - ϵ)
    
    t0 = time()
    CPLEX.optimize!(model)
    t1 = time()
    
    if CPLEX.get_status_code(model) == 101
        tmp = BOPSolution(vars=round.(CPLEX.get_solution(model)))
        compute_objective_function_value!(tmp, instance)
    else
        tmp = BOPSolution()
    end
    CPLEX.set_varLB!(model, zeros(length(instance.c1)))
    CPLEX.set_varUB!(model, ones(length(instance.c1)))
    del_constrs!(model, Cint(length(instance.cons_lb)+1), CPLEX.num_constr(model))
    del_all_warm_starts!(model)
    tmp, t1 - t0
end

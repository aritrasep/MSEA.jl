# Getting Started #

```julia
using Modof, JuMP, MSEA
```

## Warm Up FPBH: ##

It is recommended that before `msea` is used for solving any biobjective pure integer program, `warmup_msea` is used to compile it.

```julia
warmup_msea(mdls=true) # To compile mdls as well ( MDLS should be properly installed )
```

```julia
warmup_msea(mdls=false) # To compile without mdls
```

## Codes of the Primitive Algorithms: ##

|Code|Algorithm|Notation|
|:-:|:-:|:-:|
|1|Perpendicular Search Method|PSM|
|2|Binary Induced Neighbourhood Search + Perpendicular Search Method|BINS+PSM|
|3|$\epsilon$ Constraint Method using Lexicographic Minimization with the Objective Function Cuts added from Top to Down|ECM LM TD|
|4|$\epsilon$ Constraint Method using Lexicographic Minimization (MIP EMPHASIS turned to Optimality while solving the second IP) with the Objective Function Cuts added from Top to Down|ECM LM2 TD|
|5|$\epsilon$ Constraint Method using Augmented Operation with the Objective Function Cuts added from Top to Down|ECM AO TD|
|6|$\epsilon$ Constraint Method using Lexicographic Minimization with the Objective Function Cuts added from Right to Left|ECM LM RL|
|7|$\epsilon$ Constraint Method using Lexicographic Minimization (MIP EMPHASIS turned to Optimality while solving the second IP) with the Objective Function Cuts added from Right to Left|ECM LM2 RL|
|8|$\epsilon$ Constraint Method using Augmented Operation with the Objective Function Cuts added from Right to Left|ECM AO RL|
|9|Balanced Box Method using Lexicographic Minimization with the Objective Function Cuts added from Top to Down followed by Right to Left|BBM LM TDRL|
|10|Balanced Box Method using Lexicographic Minimization (MIP EMPHASIS turned to Optimality while solving the second IP) with the Objective Function Cuts added from Top to Down followed by Right to Left|BBM LM2 TDRL|
|11|Balanced Box Method using Augmented Operation with the Objective Function Cuts added from Top to Down followed by Right to Left|BBM AO TDRL|
|12|Balanced Box Method using Lexicographic Minimization with the Objective Function Cuts added from Right to Left followed by Top to Down|BBM LM RLTD|
|13|Balanced Box Method using Lexicographic Minimization (MIP EMPHASIS turned to Optimality while solving the second IP) with the Objective Function Cuts added from Right to Left followed by Top to Down|BBM LM2 RLTD|
|14|Balanced Box Method using Augmented Operation with the Objective Function Cuts added from Right to Left followed by Top to Down|BBM AO RLTD|

## Other Parameters: ##

|Parameters|Type|Description|Default Values|
|:-:|:-:|:-:|:-:|
|fpbh|Float64||0.0|
|mdls|Int64||0|
|turn_off_cplex_heur|Bool||false|
|num|Int64||1|
|threads|Int64||1|
|deterministic_exploration|Bool||true|
|minimum_dim|Bool||true|
|operations|Vector{Int64}||[1]|
|approximation|Bool||false|
|ϵ|Float64||0.99|
|log_file_name|Union{String, Void}||nothing|
|timelimit|Float64||Inf|
|message|Bool||true|

## Returns ##

|A|B|
|:-:|:-:|
||Vector of Sorted Nondominated Solutions|
||Number of Rectangles Explored|
||Number of Empty Rectangles Explored|
||Vector of Rectangles Left to Explore|
||Total Number of Singleobjective IP Solved|
||Total Time Taken by Heuristics|
||Total Time Taken by CPLEX|
||Total Time Taken|

## Algorithms Exported ##

psm, asos, ecm, ecm_ao, bbm, psm_ecm, psm_ecm_ao, bbm_ecm, bbm_ecm_ao, psm_bbm_ecm, stochastic

## Using JuMP Extension: ##

Providing the following multi-objective mixed integer linear program as a ModoModel:

$$\begin{aligned} \min \: & x_1 + x_2 + y_1 + y_2 \\ \max \: & x_1 + x_2 + y_1 + y_2 \\ \min \: & x_1 + 2x_2 + y_1 + 2y_2 \\ \text{s.t. } & x_1 + x_2 \leq 1 \\ & y_1 + 2y_2 \geq 1 \\ & x_1, x_2 \in \{0, 1\} \\ & y_1, y_2 \geq 0 \end{aligned}$$

```julia
model = ModoModel()
@variable(model, x[1:2], Bin)
@variable(model, y[1:2] >= 0.0)
objective!(model, 1, :Min, x[1] + x[2] + y[1] + y[2])
objective!(model, 2, :Max, x[1] + x[2] + y[1] + y[2])
objective!(model, 3, :Min, x[1] + 2x[2] + y[1] + 2y[2])
@constraint(model, x[1] + x[2] <= 1) 
@constraint(model, y[1] + 2y[2] >= 1)
```

**Note:** Currently constant terms in the objective functions are not supported

### Using GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds ###

```julia
@time solutions = fpbh(model, timelimit=10.0)
```

### Writing nondominated frontier to a file ###

```julia
write_nondominated_frontier(solutions, "nondominated_frontier.txt")
```

### Writing nondominated solutions to a file ###

```julia
write_nondominated_sols(solutions, "nondominated_solutions.txt")
```

### Nondominated frontier ###

```julia
nondominated_frontier = wrap_sols_into_array(solutions)
```

## Using LP File Format ##

Providing the following multiobjective mixed integer linear program as a [LP file](http://lpsolve.sourceforge.net/5.1/lp-format.htm):

$$\begin{aligned} \min \: & x_1 + x_2 + y_1 + y_2 \\ \max \: & x_1 + x_2 + y_1 + y_2 \\ \min \: & x_1 + 2x_2 + y_1 + 2y_2 \\ \text{s.t. } & x_1 + x_2 \leq 1 \\ & y_1 + 2y_2 \geq 1 \\ & x_1, x_2 \in \{0, 1\} \\ & y_1, y_2 \geq 0 \end{aligned}$$

### Format: ###

1. The first objective function should follow the convention of [LP format of single objective optimization problem](http://lpsolve.sourceforge.net/5.1/lp-format.htm)
2. **The other objective functions should be added as constraints with RHS = 0, at the end of the constraint matrix in the respective order**
3. Variables and constraints should also follow the convention of [LP format of single objective optimization problem](http://lpsolve.sourceforge.net/5.1/lp-format.htm)

```julia
write("Test.lp", "\\ENCODING=ISO-8859-1
\\Problem name: TestLPFormat

Minimize
 obj: x1 + x2 + x3 + x4
Subject To
 c1: x1 + x2 <= 1
 c2: x3 + 2 x4 >= 1
 c3: x1 + x2 + x3 + x4  = 0
 c4: x1 + 2 x2 + x3 + 2 x4  = 0
Binaries
 x1  x2 
End\n") # Writing the LP file of the above multiobjective mixed integer program to Test.lp
```

### Using GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds ###

The sense of the first objective function is automatically detected from the LP file, however the senses of the rest of the objective functions should be provided in the proper order.

```julia
@time solutions = fpbh("Test.lp", [:Max, :Min], timelimit=10.0)
```

### Using CLP instead of GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds ###

```julia
@time solutions = fpbh("Test.lp", [:Max, :Min], lp_solver=ClpSolver(), timelimit=10.0)
```

## Using MPS File Format ##

Providing the following multiobjective mixed integer linear program as a [MPS file](http://lpsolve.sourceforge.net/5.5/mps-format.htm):

$$\begin{aligned} \min \: & x_1 + x_2 + y_1 + y_2 \\ \max \: & x_1 + x_2 + y_1 + y_2 \\ \min \: & x_1 + 2x_2 + y_1 + 2y_2 \\ \text{s.t. } & x_1 + x_2 \leq 1 \\ & y_1 + 2y_2 \geq 1 \\ & x_1, x_2 \in \{0, 1\} \\ & y_1, y_2 \geq 0 \end{aligned}$$

### Format: ###

1. The first objective function should follow the convention of [MPS format of single objective optimization problem](http://lpsolve.sourceforge.net/5.5/mps-format.htm)
2. **The other objective functions should be added as constraints with RHS = 0, at the end of the constraint matrix in the respective order**
3. Variables and constraints should also follow the convention of [MPS format of single objective optimization problem](http://lpsolve.sourceforge.net/5.5/mps-format.htm)

```julia
write("Test.mps", "NAME   TestMPSFormat
ROWS
 N  OBJ
 L  CON1
 G  CON2
 E  CON3
 E  CON4
COLUMNS
    MARKER    'MARKER'                 'INTORG'
    VAR1  CON1  1
    VAR1  CON3  1
    VAR1  CON4  1
    VAR1  OBJ  1
    VAR2  CON1  1
    VAR2  CON3  1
    VAR2  CON4  2
    VAR2  OBJ  1
    MARKER    'MARKER'                 'INTEND'
    VAR3  CON2  1
    VAR3  CON3  1
    VAR3  CON4  1
    VAR3  OBJ  1
    VAR4  CON2  2
    VAR4  CON3  1
    VAR4  CON4  2
    VAR4  OBJ  1
RHS
    rhs    CON1    1
    rhs    CON2    1
    rhs    CON3    0
    rhs    CON4    0
BOUNDS
  UP BOUND VAR1 1
  UP BOUND VAR2 1
  PL BOUND VAR3
  PL BOUND VAR4
ENDATA\n") # Writing the MPS file of the above multiobjective mixed integer program to Test.mps
```

### Using GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds ###

The sense of the first objective function is automatically detected from the MPS file, however the senses of the rest of the objective functions should be provided in the proper order.

```julia
@time solutions = fpbh("Test.mps", [:Max, :Min], timelimit=10.0)
```

### Using CLP instead of GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds ###

```julia
@time solutions = fpbh("Test.mps", [:Max, :Min], lp_solver=ClpSolver(), timelimit=10.0)
```

## Using the Matrix Format - Advanced ##

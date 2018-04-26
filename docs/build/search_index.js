var documenterSearchIndex = {"docs": [

{
    "location": "index.html#",
    "page": "Home",
    "title": "Home",
    "category": "page",
    "text": ""
},

{
    "location": "index.html#MSEA:-A-Multi-Stage-Exact-Algorithm-for-Bi-Objective-Integer-Linear-Programming-1",
    "page": "Home",
    "title": "MSEA: A Multi-Stage Exact Algorithm for Bi-Objective Integer Linear Programming",
    "category": "section",
    "text": "This is a Multi-Stage Exact Algorithm for computing the true nondominated frontier of a Bi-objective Pure Integer Linear Program. Important characteristics of this algorithm are:Can solve any (both structured and unstructured) biobjective pure integer linear problem.\nA biobjective pure integer linear program can be provided as a input in 4 ways:\nModoModel - an extension of JuMP Model\nLP file format\nMPS file format\nMatrix Format ( Advanced )\nAll parameters are already tuned, only timelimit is required.\nSupports parallelization"
},

{
    "location": "index.html#Contents:-1",
    "page": "Home",
    "title": "Contents:",
    "category": "section",
    "text": "Pages = [\"installation.md\", \"getting_started.md\"]"
},

{
    "location": "index.html#Supporting-and-Citing:-1",
    "page": "Home",
    "title": "Supporting and Citing:",
    "category": "section",
    "text": "The software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. If you use MSEA.jl software as part of your research, teaching, or other activities, we would be grateful if you could cite:Pal, A. and Charkhgard, H., MSEA.jl: A Multi-Stage Exact Algorithm for Bi-Objective Integer Linear Programming in Julia"
},

{
    "location": "index.html#Contributions-1",
    "page": "Home",
    "title": "Contributions",
    "category": "section",
    "text": "This package is written and maintained by Aritra Pal. Please fork and send a pull request or create a GitHub issue for bug reports or feature requests."
},

{
    "location": "installation.html#",
    "page": "Installation",
    "title": "Installation",
    "category": "page",
    "text": ""
},

{
    "location": "installation.html#Installation:-1",
    "page": "Installation",
    "title": "Installation:",
    "category": "section",
    "text": "It is important to note that the whole ecosystem has been tested using Julia v0.6.2 and hence we can cannot guarantee whether it will work with previous versions of Julia. Thus, it is important that Julia v0.6.2 is properly installed and available on your system. CPLEX must be available in the local machine and CPLEX.jl must be properly installed, otherwise the installation will fail. Once, Julia v0.6.2 and CPLEX.jl has been properly installed, the following instructions in a Julia terminal will install MSEA.jl and its dependencies on the local machine:Pkg.clone(\"https://github.com/aritrasep/MSEA.jl\")\nPkg.build(\"MSEA\")In case Pkg.build(\"MSEA\") gives you an error on Linux, you may need to install the GMP library headers. For example, on Ubuntu/Debian and similar, give the following command from a terminal:$ sudo apt-get install libgmp-devAfter that, restart the installation of the package with:Pkg.build(\"MSEA\")"
},

{
    "location": "getting_started.html#",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "page",
    "text": ""
},

{
    "location": "getting_started.html#Getting-Started-1",
    "page": "Getting Started",
    "title": "Getting Started",
    "category": "section",
    "text": "using Modof, JuMP, MSEA"
},

{
    "location": "getting_started.html#Warm-Up-FPBH:-1",
    "page": "Getting Started",
    "title": "Warm Up FPBH:",
    "category": "section",
    "text": "It is recommended that before msea is used for solving any biobjective pure integer program, warmup_msea is used to compile it.warmup_msea(mdls=true) # To compile mdls as well ( MDLS should be properly installed )warmup_msea(mdls=false) # To compile without mdls"
},

{
    "location": "getting_started.html#Codes-of-the-Primitive-Algorithms:-1",
    "page": "Getting Started",
    "title": "Codes of the Primitive Algorithms:",
    "category": "section",
    "text": "Code Algorithm Notation\n1 Perpendicular Search Method PSM\n2 Binary Induced Neighbourhood Search + Perpendicular Search Method BINS+PSM\n3 epsilon Constraint Method using Lexicographic Minimization with the Objective Function Cuts added from Top to Down ECM LM TD\n4 epsilon Constraint Method using Lexicographic Minimization (MIP EMPHASIS turned to Optimality while solving the second IP) with the Objective Function Cuts added from Top to Down ECM LM2 TD\n5 epsilon Constraint Method using Augmented Operation with the Objective Function Cuts added from Top to Down ECM AO TD\n6 epsilon Constraint Method using Lexicographic Minimization with the Objective Function Cuts added from Right to Left ECM LM RL\n7 epsilon Constraint Method using Lexicographic Minimization (MIP EMPHASIS turned to Optimality while solving the second IP) with the Objective Function Cuts added from Right to Left ECM LM2 RL\n8 epsilon Constraint Method using Augmented Operation with the Objective Function Cuts added from Right to Left ECM AO RL\n9 Balanced Box Method using Lexicographic Minimization with the Objective Function Cuts added from Top to Down followed by Right to Left BBM LM TDRL\n10 Balanced Box Method using Lexicographic Minimization (MIP EMPHASIS turned to Optimality while solving the second IP) with the Objective Function Cuts added from Top to Down followed by Right to Left BBM LM2 TDRL\n11 Balanced Box Method using Augmented Operation with the Objective Function Cuts added from Top to Down followed by Right to Left BBM AO TDRL\n12 Balanced Box Method using Lexicographic Minimization with the Objective Function Cuts added from Right to Left followed by Top to Down BBM LM RLTD\n13 Balanced Box Method using Lexicographic Minimization (MIP EMPHASIS turned to Optimality while solving the second IP) with the Objective Function Cuts added from Right to Left followed by Top to Down BBM LM2 RLTD\n14 Balanced Box Method using Augmented Operation with the Objective Function Cuts added from Right to Left followed by Top to Down BBM AO RLTD"
},

{
    "location": "getting_started.html#Other-Parameters:-1",
    "page": "Getting Started",
    "title": "Other Parameters:",
    "category": "section",
    "text": "Parameters Type Description Default Values\nfpbh Float64  0.0\nmdls Int64  0\nturn_off_cplex_heur Bool  false\nnum Int64  1\nthreads Int64  1\ndeterministic_exploration Bool  true\nminimum_dim Bool  true\noperations Vector{Int64}  [1]\napproximation Bool  false\nϵ Float64  0.99\nlog_file_name Union{String, Void}  nothing\ntimelimit Float64  Inf\nmessage Bool  true"
},

{
    "location": "getting_started.html#Returns-1",
    "page": "Getting Started",
    "title": "Returns",
    "category": "section",
    "text": "A B\n Vector of Sorted Nondominated Solutions\n Number of Rectangles Explored\n Number of Empty Rectangles Explored\n Vector of Rectangles Left to Explore\n Total Number of Singleobjective IP Solved\n Total Time Taken by Heuristics\n Total Time Taken by CPLEX\n Total Time Taken"
},

{
    "location": "getting_started.html#Algorithms-Exported-1",
    "page": "Getting Started",
    "title": "Algorithms Exported",
    "category": "section",
    "text": "psm, asos, ecm, ecm_ao, bbm, psm_ecm, psm_ecm_ao, bbm_ecm, bbm_ecm_ao, psm_bbm_ecm, stochastic"
},

{
    "location": "getting_started.html#Using-JuMP-Extension:-1",
    "page": "Getting Started",
    "title": "Using JuMP Extension:",
    "category": "section",
    "text": "Providing the following multi-objective mixed integer linear program as a ModoModel:beginaligned min   x_1 + x_2 + y_1 + y_2  max   x_1 + x_2 + y_1 + y_2  min   x_1 + 2x_2 + y_1 + 2y_2  textst   x_1 + x_2 leq 1   y_1 + 2y_2 geq 1   x_1 x_2 in 0 1   y_1 y_2 geq 0 endalignedmodel = ModoModel()\n@variable(model, x[1:2], Bin)\n@variable(model, y[1:2] >= 0.0)\nobjective!(model, 1, :Min, x[1] + x[2] + y[1] + y[2])\nobjective!(model, 2, :Max, x[1] + x[2] + y[1] + y[2])\nobjective!(model, 3, :Min, x[1] + 2x[2] + y[1] + 2y[2])\n@constraint(model, x[1] + x[2] <= 1) \n@constraint(model, y[1] + 2y[2] >= 1)Note: Currently constant terms in the objective functions are not supported"
},

{
    "location": "getting_started.html#Using-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-1",
    "page": "Getting Started",
    "title": "Using GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "@time solutions = fpbh(model, timelimit=10.0)"
},

{
    "location": "getting_started.html#Writing-nondominated-frontier-to-a-file-1",
    "page": "Getting Started",
    "title": "Writing nondominated frontier to a file",
    "category": "section",
    "text": "write_nondominated_frontier(solutions, \"nondominated_frontier.txt\")"
},

{
    "location": "getting_started.html#Writing-nondominated-solutions-to-a-file-1",
    "page": "Getting Started",
    "title": "Writing nondominated solutions to a file",
    "category": "section",
    "text": "write_nondominated_sols(solutions, \"nondominated_solutions.txt\")"
},

{
    "location": "getting_started.html#Nondominated-frontier-1",
    "page": "Getting Started",
    "title": "Nondominated frontier",
    "category": "section",
    "text": "nondominated_frontier = wrap_sols_into_array(solutions)"
},

{
    "location": "getting_started.html#Using-LP-File-Format-1",
    "page": "Getting Started",
    "title": "Using LP File Format",
    "category": "section",
    "text": "Providing the following multiobjective mixed integer linear program as a LP file:beginaligned min   x_1 + x_2 + y_1 + y_2  max   x_1 + x_2 + y_1 + y_2  min   x_1 + 2x_2 + y_1 + 2y_2  textst   x_1 + x_2 leq 1   y_1 + 2y_2 geq 1   x_1 x_2 in 0 1   y_1 y_2 geq 0 endaligned"
},

{
    "location": "getting_started.html#Format:-1",
    "page": "Getting Started",
    "title": "Format:",
    "category": "section",
    "text": "The first objective function should follow the convention of LP format of single objective optimization problem\nThe other objective functions should be added as constraints with RHS = 0, at the end of the constraint matrix in the respective order\nVariables and constraints should also follow the convention of LP format of single objective optimization problemwrite(\"Test.lp\", \"\\\\ENCODING=ISO-8859-1\n\\\\Problem name: TestLPFormat\n\nMinimize\n obj: x1 + x2 + x3 + x4\nSubject To\n c1: x1 + x2 <= 1\n c2: x3 + 2 x4 >= 1\n c3: x1 + x2 + x3 + x4  = 0\n c4: x1 + 2 x2 + x3 + 2 x4  = 0\nBinaries\n x1  x2 \nEnd\\n\") # Writing the LP file of the above multiobjective mixed integer program to Test.lp"
},

{
    "location": "getting_started.html#Using-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-2",
    "page": "Getting Started",
    "title": "Using GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "The sense of the first objective function is automatically detected from the LP file, however the senses of the rest of the objective functions should be provided in the proper order.@time solutions = fpbh(\"Test.lp\", [:Max, :Min], timelimit=10.0)"
},

{
    "location": "getting_started.html#Using-CLP-instead-of-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-1",
    "page": "Getting Started",
    "title": "Using CLP instead of GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "@time solutions = fpbh(\"Test.lp\", [:Max, :Min], lp_solver=ClpSolver(), timelimit=10.0)"
},

{
    "location": "getting_started.html#Using-MPS-File-Format-1",
    "page": "Getting Started",
    "title": "Using MPS File Format",
    "category": "section",
    "text": "Providing the following multiobjective mixed integer linear program as a MPS file:beginaligned min   x_1 + x_2 + y_1 + y_2  max   x_1 + x_2 + y_1 + y_2  min   x_1 + 2x_2 + y_1 + 2y_2  textst   x_1 + x_2 leq 1   y_1 + 2y_2 geq 1   x_1 x_2 in 0 1   y_1 y_2 geq 0 endaligned"
},

{
    "location": "getting_started.html#Format:-2",
    "page": "Getting Started",
    "title": "Format:",
    "category": "section",
    "text": "The first objective function should follow the convention of MPS format of single objective optimization problem\nThe other objective functions should be added as constraints with RHS = 0, at the end of the constraint matrix in the respective order\nVariables and constraints should also follow the convention of MPS format of single objective optimization problemwrite(\"Test.mps\", \"NAME   TestMPSFormat\nROWS\n N  OBJ\n L  CON1\n G  CON2\n E  CON3\n E  CON4\nCOLUMNS\n    MARKER    \'MARKER\'                 \'INTORG\'\n    VAR1  CON1  1\n    VAR1  CON3  1\n    VAR1  CON4  1\n    VAR1  OBJ  1\n    VAR2  CON1  1\n    VAR2  CON3  1\n    VAR2  CON4  2\n    VAR2  OBJ  1\n    MARKER    \'MARKER\'                 \'INTEND\'\n    VAR3  CON2  1\n    VAR3  CON3  1\n    VAR3  CON4  1\n    VAR3  OBJ  1\n    VAR4  CON2  2\n    VAR4  CON3  1\n    VAR4  CON4  2\n    VAR4  OBJ  1\nRHS\n    rhs    CON1    1\n    rhs    CON2    1\n    rhs    CON3    0\n    rhs    CON4    0\nBOUNDS\n  UP BOUND VAR1 1\n  UP BOUND VAR2 1\n  PL BOUND VAR3\n  PL BOUND VAR4\nENDATA\\n\") # Writing the MPS file of the above multiobjective mixed integer program to Test.mps"
},

{
    "location": "getting_started.html#Using-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-3",
    "page": "Getting Started",
    "title": "Using GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "The sense of the first objective function is automatically detected from the MPS file, however the senses of the rest of the objective functions should be provided in the proper order.@time solutions = fpbh(\"Test.mps\", [:Max, :Min], timelimit=10.0)"
},

{
    "location": "getting_started.html#Using-CLP-instead-of-GLPK-as-the-underlying-LP-Solver,-and-imposing-a-maximum-timelimit-of-10.0-seconds-2",
    "page": "Getting Started",
    "title": "Using CLP instead of GLPK as the underlying LP Solver, and imposing a maximum timelimit of 10.0 seconds",
    "category": "section",
    "text": "@time solutions = fpbh(\"Test.mps\", [:Max, :Min], lp_solver=ClpSolver(), timelimit=10.0)"
},

{
    "location": "getting_started.html#Using-the-Matrix-Format-Advanced-1",
    "page": "Getting Started",
    "title": "Using the Matrix Format - Advanced",
    "category": "section",
    "text": ""
},

]}

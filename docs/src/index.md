# MSEA: A Multi-Stage Exact Algorithm for Bi-Objective Integer Linear Programming #

This is a Multi-Stage Exact Algorithm for computing the true nondominated frontier of a Bi-objective Pure Integer Linear Program. Important characteristics of this algorithm are:

1. Can solve any (both structured and unstructured) biobjective pure integer linear problem.
2. A biobjective pure integer linear program can be provided as a input in 4 ways:
    1. ModoModel - an extension of JuMP Model
    2. LP file format
    3. MPS file format
    4. Matrix Format ( Advanced )
3. All parameters are already tuned, only timelimit is required.
4. Supports parallelization

## Contents: ##

```@contents
Pages = ["installation.md", "getting_started.md"]
```

## Supporting and Citing: ##

The software in this ecosystem was developed as part of academic research. If you would like to help support it, please star the repository as such metrics may help us secure funding in the future. If you use [MSEA.jl](https://github.com/aritrasep/MSEA.jl) software as part of your research, teaching, or other activities, we would be grateful if you could cite:

1. [Pal, A. and Charkhgard, H., MSEA.jl: A Multi-Stage Exact Algorithm for Bi-Objective Integer Linear Programming in Julia](http://www.optimization-online.org/DB_FILE/2017/09/6195.pdf)

## Contributions ##

This package is written and maintained by [Aritra Pal](https://github.com/aritrasep). Please fork and send a pull request or create a [GitHub issue](https://github.com/aritrasep/MSEA.jl/issues) for bug reports or feature requests.

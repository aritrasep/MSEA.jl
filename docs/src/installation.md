# Installation: #

It is important to note that the whole ecosystem has been tested using [Julia v0.6.2](https://julialang.org/downloads/) and hence we can cannot guarantee whether it will work with previous versions of Julia. Thus, it is important that [Julia v0.6.2](https://julialang.org/downloads/) is properly installed and available on your system. [CPLEX](https://www-01.ibm.com/software/commerce/optimization/cplex-optimizer/) must be available in the local machine and [CPLEX.jl](https://github.com/JuliaOpt/CPLEX.jl) must be properly installed, otherwise the installation will fail. Once, `Julia v0.6.2` and `CPLEX.jl` has been properly installed, the following instructions in a **Julia** terminal will install **MSEA.jl** and its dependencies on the local machine:

```julia
Pkg.clone("https://github.com/aritrasep/MSEA.jl")
Pkg.build("MSEA")
```

In case `Pkg.build("MSEA")` gives you an error on Linux, you may need to install the GMP library headers. For example, on Ubuntu/Debian and similar, give the following command from a terminal:

```
$ sudo apt-get install libgmp-dev
```

After that, restart the installation of the package with:

```
Pkg.build("MSEA")
```

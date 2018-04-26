using Documenter, MSEA

makedocs(modules=[MSEA],
         doctest = false,
         format = :html,
         sitename = "MSEA",
         authors = "Aritra Pal",
         pages = Any[
        	"Home" => "index.md",
        	"Installation" => "installation.md",
        	"Getting Started" => "getting_started.md"
    	])

deploydocs(
	repo = "github.com/aritrasep/MSEA.jl.git",
    target = "build",
    osname = "linux",
    julia  = "0.6",
    deps   = nothing,
    make   = nothing
)

if !("FPBHCPLEX" in keys(Pkg.installed()))
	Pkg.clone("https://github.com/aritrasep/FPBHCPLEX.jl")
	Pkg.build("FPBHCPLEX")
end

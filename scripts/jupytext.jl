#using Pkg
#Pkg.activate(@__DIR__)
#Pkg.instantiate()
#using IJulia; installkernel("Julia", "--project=@.")
using PythonCall

jupytext = joinpath(dirname(PythonCall.C.CTX.exe_path), "jupytext")

for jlfile in ARGS
	run(`$(jupytext) --to ipynb --set-kernel=julia-$(VERSION.major).$(VERSION.minor) $(jlfile)`)
end

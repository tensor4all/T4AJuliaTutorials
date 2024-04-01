#using Pkg
#Pkg.activate(@__DIR__)
#Pkg.instantiate()
#using IJulia; installkernel("Julia", "--project=@.")
using PythonCall

jupytext = joinpath(dirname(PythonCall.C.CTX.exe_path), "jupytext")

for jlfile in ARGS
	destination = joinpath("ipynbs", splitext(jlfile)[begin] * ".ipynb")
	run(`$(jupytext) --to ipynb --set-kernel=julia-$(VERSION.major).$(VERSION.minor) $(jlfile) --output $(destination)`)
end

#using Pkg
#Pkg.activate(@__DIR__)
#Pkg.instantiate()
#using IJulia; installkernel("Julia", "--project=@.")
using PythonCall

python = PythonCall.C.CTX.exe_path

for jlfile in ARGS
	destination = joinpath("ipynbs", splitext(jlfile)[begin] * ".ipynb")
	run(`$(python) -m jupytext --to ipynb --set-kernel=julia-$(VERSION.major).$(VERSION.minor) $(jlfile) --output $(destination)`)
end

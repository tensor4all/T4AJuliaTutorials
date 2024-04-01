#using Pkg
#Pkg.activate(@__DIR__)
#Pkg.instantiate()
#using IJulia; installkernel("Julia", "--project=@.")
using PythonCall

jbpath = joinpath(dirname(PythonCall.C.CTX.exe_path), "jupyter-book")

run(`$(jbpath) build $(pwd())`)

#using Pkg
#Pkg.activate(@__DIR__)
#Pkg.instantiate()
#using IJulia; installkernel("Julia", "--project=@.")
using PythonCall

if Sys.iswindows()
    jbpath = joinpath(pwd(), ".CondaPkg", "env", "Scripts", "jb.exe")
    run(`$jbpath build $(pwd())`)
else
    jbpath = joinpath(dirname(PythonCall.C.CTX.exe_path), "jupyter-book")
    run(`$(jbpath) build $(pwd()) --warningiserror`)
end

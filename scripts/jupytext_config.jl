using PythonCall

jupytext_config = joinpath(dirname(PythonCall.C.CTX.exe_path), "jupytext-config")

run(`$(jupytext_config) set-default-viewer`)

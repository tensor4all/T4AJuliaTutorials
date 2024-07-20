using PythonCall

if Sys.iswindows()
    jbpath = joinpath(pwd(), ".CondaPkg", "env", "Scripts", "jb.exe")
    #=
    We omit --warningiserror flag on Windows because of the following warning happens, which is not related to our Julia project:
    
    RuntimeWarning: Proactor event loop does not implement add_reader family of methods required for zmq.
    Registering an additional selector thread for add_reader support via tornado.
    Use `asyncio.set_event_loop_policy(WindowsSelectorEventLoopPolicy())` to avoid this warning. self._get_loop()
    
    =#
    run(`$jbpath build $(pwd())`)
else
    jbpath = joinpath(dirname(PythonCall.C.CTX.exe_path), "jupyter-book")
    run(`$(jbpath) build $(pwd()) --warningiserror`)
end

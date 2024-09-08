using Pkg

Pkg.Registry.add("General")
Pkg.instantiate()

using Conda

if Sys.iswindows()
	isfile(joinpath(Conda.PYTHONDIR, "jupyter.exe")) || Conda.add("jupyter")
	isfile(joinpath(Conda.PYTHONDIR, "jupytext.exe")) || Conda.add("jupytext")
	isfile(joinpath(Conda.PYTHONDIR, "jb.exe")) || Conda.add("jupyter-book")
else
	isfile(joinpath(Conda.PYTHONDIR, "jupyter")) || Conda.add("jupyter")
	isfile(joinpath(Conda.PYTHONDIR, "jupytext")) || Conda.add("jupytext")
	isfile(joinpath(Conda.PYTHONDIR, "jupyter-book")) || Conda.add("jupyter-book")
end

Pkg.build("IJulia")
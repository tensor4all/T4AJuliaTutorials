using Pkg

Pkg.Registry.add("General")
Pkg.instantiate()

using Conda

if Sys.iswindows()
	isfile(joinpath(Conda.SCRIPTDIR, "jupyter.exe")) || Conda.add("jupyter")
	isfile(joinpath(Conda.SCRIPTDIR, "jupytext.exe")) || Conda.add("jupytext")
	isfile(joinpath(Conda.SCRIPTDIR, "jupyter-book.exe")) || Conda.add("jupyter-book")
else
	isfile(joinpath(Conda.SCRIPTDIR, "jupyter")) || Conda.add("jupyter")
	isfile(joinpath(Conda.SCRIPTDIR, "jupytext")) || Conda.add("jupytext")
	isfile(joinpath(Conda.SCRIPTDIR, "jupyter-book")) || Conda.add("jupyter-book")
end

Pkg.build("IJulia")
using Pkg

using Conda

Pkg.Registry.add("General")
Pkg.instantiate()
Pkg.build("IJulia")

Conda.add("jupytext")
Conda.add("jupyter-book")
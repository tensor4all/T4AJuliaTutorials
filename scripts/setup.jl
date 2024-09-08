using Pkg

Pkg.Registry.add("General")
Pkg.instantiate()

using Conda

Conda.add("jupyter")
Conda.add("jupytext")
Conda.add("jupyter-book")

Pkg.build("IJulia")
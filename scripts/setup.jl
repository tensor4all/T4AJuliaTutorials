using Pkg

Pkg.Registry.add("General")
Pkg.instantiate()
Pkg.build("IJulia")

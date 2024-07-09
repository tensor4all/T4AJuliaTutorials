using Pkg

Pkg.Registry.add("General")
Pkg.Registry.add(RegistrySpec(url="https://github.com/tensor4all/T4ARegistry.git"))
Pkg.instantiate()
Pkg.build("IJulia")

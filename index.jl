# ---
# jupyter:
#   jupytext:
#     custom_cell_magics: kql
#     formats: ipynb,jl:percent
#     text_representation:
#       extension: .jl
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.11.2
#   kernelspec:
#     display_name: Julia 1.10.3
#     language: julia
#     name: julia-1.10
# ---

# %% [markdown]
# # T4A Julia Tutorials
#
# This documentation provides a comprehensive tutorials/examples
# on quantics and tensor cross interpolation (TCI) and their combinations (QTCI).
# These technologies allow us to reveal low-rank tensor network representation (TNR) hidden in data or a function,
# and perform computation such as Fourier transform and convolution.
# Please refer [xfacpaper](https://arxiv.org/abs/2407.02454) for a more detailed introduction of these concepts.
#
# The T4A group hosts various Julia libraries for performing such operations.
# The folowing list is given in the order of low-level to high-level libraries:
#
# - [TensorCrossInterpolation.jl](https://github.com/tensor4all/TensorCrossInterpolation.jl/) provides implementations of TCI.
# - [QuanticsGrids.jl](https://github.com/tensor4all/QuanticsGrids.jl/) provides utilities for handling quantics representations, e.g., creating a quantics grid and transformation between the original coordinate system and the quantics representation.
# - [QuanticsTCI.jl](https://github.com/tensor4all/QuanticsTCI.jl/) is a thin wrapper around `TensorCrossInterpolation.jl` and `QuanticsGrids.jl`, providing valuable functionalities for non-expert users' performing quantics TCI (QTCI).
# - [TCIITensorConversion.jl](https://github.com/tensor4all/TCIITensorConversion.jl/) provides conversions of tensor trains between `TensorCrossInterpolation.jl` and `ITensors.jl`.
# - [Quantics.jl](https://github.com/tensor4all/Quantics.jl/) is an experimental library providing a high-level API for performing operations in QTT. This library is under development and its API may be subject to change. The library is not yet registered in the Julia package registry.
#
# Additionally, we provide some topics on Julia packages such as:
#
# - [Plots.jl](plots.ipynb). Basic tutorial for plotting using Plots.jl.
#
# To build our page locally, refer [developer guilde](developer_guide.ipynb).
#
# A detailed guide to setting up the software is available at [T4AJuliaTutorials/Wiki](https://github.com/tensor4all/T4AJuliaTutorials/wiki).
#
# ## Preparation - Installing Julia
#
# Install `julia` command using [juliaup](https://github.com/JuliaLang/juliaup).
#
# On Windows Julia and Juliaup can be installed directly from the Windows store. One can also install exactly the same version by executing
#

# %% [markdown]
# ```powershell
# PS> winget install julia -s msstore
# ```
#

# %% [markdown]
# on a command line.
#
# Juliaup can be installed on Linux or Mac by executing
#

# %% [markdown]
# ```sh
# $ curl -fsSL https://install.julialang.org | sh
# ```
#

# %% [markdown]
# in a shell.
#
# You can check that `julia` is installed correctly by simply running `julia` in your terminal:
#
# ```julia-repl
#                _
#    _       _ _(_)_     |  Documentation: https://docs.julialang.org
#   (_)     | (_) (_)    |
#    _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
#   | | | | | | |/ _` |  |
#   | | |_| | | | (_| |  |  Version 1.10.1 (2024-02-13)
#  _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
# |__/                   |
#
# julia>
# ```
#
# The REPL greets you with a banner and a `julia>` prompt. Let's display "Hello World":
#
# ```julia-repl
# julia> println("Hello World")
# ```
#
# To see the environment in which Julia is running, you can use `versioninfo()`.
#
# ```julia-repl
# julia> versioninfo()
# ```
#
# To exit the interactive session, type `exit()` followed by the return or enter key:
#
# ```julia-repl
# julia> exit()
# ```
#
# See the official documentation at [The Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/) to learn more.

# %% [markdown]
# ## Run notebooks
#
# 1. Download all the notebooks as [a zip file](https://github.com/tensor4all/T4AJuliaTutorials/releases/download/ipynbs%2Fpreview/ipynbs.zip).
# 1. Double click `ipynbs.zip` to extract the zip file. You will get a directory named `ipynbs`.
# 1. Open a terminal and change the directory to the `ipynbs` directory. Then, open a Julia REPL using the `ipynbs` directory as the project directory.
#     ```sh
#     $ cd ipynbs
#    $ ls
#        Manifest.toml                 plots.ipynb
#        Project.toml                  qft.ipynb
#        compress.ipynb                quantics1d.ipynb
#        index.ipynb                   quantics1d_advanced.ipynb
#        interfacingwithitensors.ipynb quantics2d.ipynb
#     $ julia --project=@.
#     ```
# 1. Run the following commands in the Julia REPL to install the required packages, which are registered in `ipynbs/Project.toml`, and open the Jupyter notebook.
#
# ```julia-repl
# julia> using Pkg
# julia> Pkg.instantiate() # Install the required packages. This may take a while.
# julia> using IJulia
# julia> IJulia.notebook(;dir=pwd()) # Open the Jupyter notebook.
# ```
#

# %% [markdown]
# Here, the `--project` option activates our project, which is characterized by `ipynbs/Project.toml`, and `Pkg.instantiate()` installs dependencies needed to run our notebooks.
# `Pkg.instantiate()` may take a while to complete, as it downloads and installs the required packages.
# This command only needs to be run once, unless the `Project.toml` file is modified.

# %% [markdown]
# We do not recommend to run the notebook in Safari because it may cause some issues.
# If you want to use another browser to open the notebook, you can use the following command:
#
# ```julia-repl
# julia> browser="chrome"  # specify your browser name: see https://docs.python.org/3/library/webbrowser.html#webbrowser.register
# julia> cmd = `$(IJulia.JUPYTER) notebook --browser=$(browser)`
# julia> run(Cmd(cmd; dir=pwd()); wait=false)
# ```

# %% [markdown]
# ## Print out the status of the project
#
# Having trouble? Try the following command in your Julia's REPL:
#
#

# %%
using Dates;
now(UTC);
VERSION # display Julia version
using Pkg;
Pkg.status();

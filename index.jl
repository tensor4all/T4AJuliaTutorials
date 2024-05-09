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
# This documentation provides a comprehensive tutorials/examples
# on quantics and tensor cross interpolation (TCI) and their combinations (QTCI).
# These technologies allow us to reveal low-rank tensor network representation (TNR) hidden in data or a function,
# and peform computation such as Fourier transform and convolution.
# Plesae refer [xfacpaper]() for a more detailed introduction of these concepts.
#
# The T4F group hosts various Julia libraries for performing such operations.
# The folowing list is given in the order of low-level to high-level libraries:
#
# * [TensorCrossInterpolation.jl](https://tensors4fields.gitlab.io/tensorcrossinterpolation.jl/dev/index.html) provides implementations of TCI.
# * [QuanticsGrids.jl](https://gitlab.com/tensors4fields/quanticstci.jl/-/blob/main/README.md?ref_type=heads) provides utilities for handing quantics representations, e.g., creating a quantics grid and transformation between the original coordinate system and the quantics representation.
# * [QuanticsTCI.jl](https://tensors4fields.gitlab.io/quanticstci.jl/dev/index.html) is a thin wrapper around `TensorCrossInterpolation.jl` and `QuanticsGrids.jl`, providing valuable functionalities for non-expert users' performing quantics TCI (QTCI).
# * [TCIITensorConversion.jl](https://gitlab.com/tensors4fields/tciitensorconversion.jl) provides conversions of tensor trains between `TensorCrossInterpolation.jl` and `ITensors.jl`.
#
# This documentation provides examples of using these libraries to perform QTCI and other operations.
#
# ## Preparation
#
# ### Install Julia
#
# Install `julia` command using [juliaup](https://github.com/JuliaLang/juliaup).
#
# On Windows Julia and Juliaup can be installed directly from the Windows store. One can also install exactly the same version by executing

# %% [markdown]
# ```powershell
# PS> winget install julia -s msstore
# ```

# %% [markdown]
# on a command line.
#
# Juliaup can be installed on Linux or Mac by executing

# %% [markdown]
# ```sh
# $ curl -fsSL https://install.julialang.org | sh
# ```

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
#
# ### Install required packages
#
# One can install required packages by running the following command on your shell:

# %% [markdown]
# ```sh
# $ julia -e 'using Pkg; Pkg.add(["QuanticsTCI", "QuanticsGrids", "TensorCrossInterpolation", "TCIITensorConversion", "ITensors", "Plots", "PythonPlot", "LaTeXStrings"])'
# ```

# %% [markdown]
# This will install required packages to Julia's global envrironment.

# %% [markdown]
# ### Print out the status of the project
#
# Having trouble? Try the following command in your Julia's REPL. On GitHub Actions instance we'll get:

# %%
using Dates; now(UTC)
VERSION # display Julia version
using Pkg; Pkg.status()

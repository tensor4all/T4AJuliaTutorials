# ---
# jupyter:
#   jupytext:
#     cell_metadata_filter: -all
#     custom_cell_magics: kql
#     text_representation:
#       extension: .jl
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.11.2
#   kernelspec:
#     display_name: Julia 1.10.2
#     language: julia
#     name: julia-1.10
# ---

# %% [markdown]
# Click [here](https://tensor4all.org/T4AJuliaTutorials/_sources/ipynbs/interfacingwithitensors.ipynb) to download the notebook locally.
#

# %% [markdown]
# # Interfacing with ITensors.jl
#
# You can convert a TCI object to an ITensor MPS object using the `TCIITensorConversion.jl` library. This library provides conversions of tensor trains between `TensorCrossInterpolation.jl` and `ITensors.jl`.
#
# We first construct a TCI object:
#

# %%
import QuanticsGrids as QG
using QuanticsTCI: quanticscrossinterpolate

B = 2^(-30) # global variable
function f(x)
    return cos(x / B) * cos(x / (4 * sqrt(5) * B)) * exp(-x^2) + 2 * exp(-x)
end

R = 40 # number of bits
xmin = 0.0
xmax = 3.0
qgrid = QG.DiscretizedGrid{1}(R, xmin, xmax; includeendpoint=false)
ci, ranks, errors = quanticscrossinterpolate(Float64, f, qgrid; maxbonddim=15)

# %% [markdown]
# One can create a tensor train object from the TCI object, and then convert it to an ITensor MPS:
#

# %%
import TensorCrossInterpolation as TCI

# Construct a TensorTrain object from the TensorCI2 object

tt = TCI.TensorTrain(ci.tci)

# Convert the TensorTrain object to an ITensor MPS object

using TCIITensorConversion
using ITensors

M = ITensors.MPS(tt)


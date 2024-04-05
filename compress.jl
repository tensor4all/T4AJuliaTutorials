# -*- coding: utf-8 -*-
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
#     display_name: Julia 1.10.2
#     language: julia
#     name: julia-1.10
# ---

# %% [markdown]
# # Compressing exisiting data

# %% [markdown]
# ## TCI
#
# Let us demonstrate how to compress exisiting data by TCI.
# First, we create a test dataset on a 3D grid.

# %%
# Replace this line with the dataset to be tested for compressibility.
grid = range(-pi, pi; length=200)
dataset = [cos(x) + cos(y) + cos(z) for x in grid, y in grid, z in grid]
size(dataset)

# %% [markdown]
# We now construct a TCI.

# %%
import TensorCrossInterpolation as TCI

# Construct TCI
tolerance = 1e-5
tt, ranks, errors = TCI.crossinterpolate2(
    Float64, i -> dataset[i...], collect(size(dataset)), tolerance=tolerance)

# Check error
ttdataset = [tt([i, j, k]) for i in axes(grid, 1), j in axes(grid, 1), k in axes(grid, 1)]
errors = abs.(ttdataset .- dataset)
println(
    "TCI of the dataset with tolerance $tolerance has link dimensions $(TCI.linkdims(tt)), "
    * "for a max error of $(maximum(errors))."
)

# %% [markdown]
# Let us plot the original data and the TCI error on a 2D cut.

# %%
using PythonPlot: pyplot as plt, gcf

fig, axs = plt.subplots(1, 2; figsize=(12.8, 4.8))

# Original data
c = axs[0].pcolor(dataset[:, :, 1])
fig.colorbar(c, ax=axs[0])
axs[0].set_title("Original data")

# TCI error
c = axs[1].pcolor(log10.(abs.(errors[:, :, 1])))
fig.colorbar(c, ax=axs[1])
axs[1].set_title("log10 of abs error of TCI")

display(gcf())

# %% [markdown]
# ## QTCI
#
# We now demonstrate how to compress existing data by QTCI.

# %%
# Number of bits
R = 8

# Replace with your dataset
grid = range(-pi, pi; length=2^R+1)[1:end-1] # exclude the end point
dataset = [cos(x) + cos(y) + cos(z) for x in grid, y in grid, z in grid]
size(dataset)

# %% [markdown]
# ### QuanticsTCI.jl
# Let us first use `quanticscrossinterpolate` function in `QuanticsTCI.jl`.

# %%
using QuanticsTCI
import TensorCrossInterpolation as TCI

# Perform QTCI
tolerance = 1e-5
qtt, ranks, errors = quanticscrossinterpolate(
    dataset, tolerance=tolerance, unfoldingscheme=:fused)

# %% [markdown]
# Below, we compute the error for the whole tensor, which may be too expensive for a large $\mathcal{R}$.

# %%
# Check error
qttdataset = [qtt([i, j, k]) for i in axes(grid, 1), j in axes(grid, 1), k in axes(grid, 1)]
qtterrors = abs.(qttdataset .- dataset)
println(
    "Quantics TCI compression of the dataset with tolerance $tolerance has " *
    "link dimensions $(TCI.linkdims(qtt.tci)), for a max error of $(maximum(qtterrors))."
)

# %% [markdown]
# Again, let us plot the original data and the TCI error on a 2D cut.

# %%
using PythonPlot: pyplot as plt, gcf

fig, axs = plt.subplots(1, 2; figsize=(12.8, 4.8))

# Original data
c = axs[0].pcolor(qttdataset[:, :, 1])
fig.colorbar(c, ax=axs[0])
axs[0].set_title("Original data")

# TCI error
c = axs[1].pcolor(log10.(abs.(qtterrors[:, :, 1])))
fig.colorbar(c, ax=axs[1])
axs[1].set_title("log10 of abs error of QTCI")

display(gcf())

# %% [markdown]
# ### QuanticsGrids.jl + TensorCrossInterpolation.jl
#
# `QuanticsTCI.jl` is user-friendly, yet utilizing `QuanticsGrids.jl` directly provides greater flexibility.

# %%
import QuanticsGrids as QG


function create_qgrid(R, qttdataset)
    # 3D quantics grid with R bits and the fused reprensentation (default)
    qgrid = QG.InherentDiscreteGrid{3}(R)

    # Function that returns the value of the dataset at the given quantics index
    qf(qindex) = qttdataset[QG.quantics_to_grididx(qgrid, qindex)...]

    return qgrid, qf
end

qgrid, qf = create_qgrid(R, qttdataset)

# Data at the quantics index [1, 1, ..., 1] = the index [1, 1, 1].
qf(fill(1, R)) == qttdataset[1, 1, 1]

# %% [markdown]
# The `create_qgrid` function generates a 3D quantics grid and a closure (`qf`) for dataset access based on quantics indices, given a grid resolution (`R`) and a dataset (`qttdataset`).
# This design reduces reliance on global variables, leading to faster function evalulations.

# %% [markdown]
# The effectiveness of TCI significantly depends on selecting appropriate initial pivots.
# Optimal initial pivots are locations where the function intended for interpolation exhibits large absolute values.

# %%
# Local dimensions
localdims = fill(8, R)

# Generate initial pivots by maximainzing the aboslute value of the function from random points.
# This is a heuristic to find good initial pivots.
# The optimization is performed by single-sites updates.
ninitialpivots = 10
initialpivots = [TCI.optfirstpivot(qf, localdims, [rand(1:d) for d in localdims]) for _ in 1:ninitialpivots]

for p in initialpivots
    println("Initial pivot: $p $(qf(p))")
end

# %%
# Perform (Q)TCI
tolerance = 1e-5
qtt, ranks, errors = TCI.crossinterpolate2(Float64, qf, localdims, initialpivots; tolerance=tolerance)

# %%
# Test error
qtt(initialpivots[1]) ≈ qf(initialpivots[1])

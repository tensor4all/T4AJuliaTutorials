# -*- coding: utf-8 -*-
# ---
# jupyter:
#   jupytext:
#     cell_metadata_filter: -all
#     custom_cell_magics: kql
#     formats: ipynb,jl:percent
#     text_representation:
#       extension: .jl
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.11.2
#   kernelspec:
#     display_name: Julia 1.10.5
#     language: julia
#     name: julia-1.10
# ---

# %% [markdown]
# Click [here](https://tensor4all.org/T4AJuliaTutorials/_sources/ipynbs/quantics2d.ipynb) to download the notebook locally.
#

# %% [markdown]
# # Quantics TCI of multivariate function
#

# %%
using Printf

using LaTeXStrings
using Plots
gr() # Use GR backend for plotting

import TensorCrossInterpolation as TCI
import QuanticsGrids: DiscretizedGrid, origcoord_to_quantics, origcoord_to_grididx, grididx_to_origcoord
using QuanticsTCI

# %% [markdown]
# ## Artificial function with widely different length scales
#
# As in the univariate case, we first demonstrate the multivariate case on an artificial function with widely different length scales:
#

# %%
f(x, y) = (exp(-0.4 * (x^2 + y^2)) + 1 + sin(x * y) * exp(-x^2) +
           cos(3 * x * y) * exp(-y^2) + cos(x + y)) +
          0.05 * cos(1 / 0.001 * (0.2 * x - 0.4 * y)) +
          0.0005 * cos(1 / 0.0001 * (-0.2 * x + 0.7 * y)) +
          1e-5 * cos(1 / 1e-7 * (20 * x))

# %% [markdown]
# To construct a 2D quantics grid, put `2` in the type parameter of `DiscretizedGrid`, and use tuples to specify lower and upper limits in each dimension:

# %%
R = 40
grid = DiscretizedGrid{2}(R, (-5, -5), (5, 5))

# %% [markdown]
# To illustrate the different length scales, we show a series of progressively smaller parts of the function domain in the following.

# %%
function myplotheatmap!(plt, f, xlim::Tuple, ylim::Tuple; xlim_box=nothing, ylim_box=nothing)
    x = LinRange(xlim..., 400)
    y = LinRange(ylim..., 400)
    s = heatmap!(plt, x, y, f)

    if !isnothing(xlim_box) && !isnothing(ylim_box)
        plot!(
            plt,
            [xlim_box[1], xlim_box[2], xlim_box[2], xlim_box[1], xlim_box[1]],
            [ylim_box[1], ylim_box[1], ylim_box[2], ylim_box[2], ylim_box[1]],
            color="lightgreen", lw=2, label="",
        )
    end
    xlabel!(L"$x$")
    ylabel!(L"$y$")
    plt
end

function myplotheatmap(func, xlim::Tuple, ylim::Tuple; xlim_box=nothing, ylim_box=nothing)
    plt = plot(xlim=xlim, ylim=ylim, aspect_ratio=:equal, xlabel=L"$x$", ylabel=L"$y$")
    myplotheatmap!(plt, func, xlim, ylim; xlim_box=xlim_box, ylim_box=ylim_box)
end

# %%
myplotheatmap(f, (-5, 5), (-5, 5), xlim_box=(0.25, 1.75), ylim_box=(1.25, 2.75))

# %%
myplotheatmap(f, (0.25, 1.75), (1.25, 2.75), xlim_box=(0.94, 1.0), ylim_box=(1.84, 1.9))

# %%
myplotheatmap(f, (0.94, 1.0), (1.84, 1.9), xlim_box=(0.97, 0.97 + 1e-7), ylim_box=(1.88, 1.88 + 1e-7))

# %%
xs = LinRange(0.97, 0.97 + 1e-7, 400)
ys = LinRange(1.88, 1.88 + 1e-7, 400)

(hm, cb) = let
    # currently GR backend does not support colorbar_ticks
    # https://github.com/JuliaPlots/Plots.jl/issues/3560
    # we manually create a colorbar using with vertical heatmap.
    n = 100
    colors = cgrad(:inferno, n, categorical=false)
    hm = heatmap(
        xs, ys, f, aspect_ratio=:equal,
        color=colors, colorbar=false,
        xticks=([0.97, 0.97 + 0.9e-7], ["0.97", "0.97+1e-7"]),
        yticks=([1.88, 1.88 + 1e-7], ["1.88", "1.88" * "\n" * "+1e-7"])
    )

    m = minimum(f.(xs, ys'))
    M = maximum(f.(xs, ys'))
    _yy = _xx = range(0, 1, n)
    cb = heatmap(
        _xx, _yy, (x, y) -> y,
        ticks=false,
        ratio=20,
        legend=false,
        fillcolor=colors,
        lims=(0, 1),
        framestyle=:box,
    )
    mstr = @sprintf "%.7f" m
    Mstr = @sprintf "%.7f" M
    annotate!(cb, 3, 0, text(mstr, 8))
    annotate!(cb, 3, 1, text(Mstr, 8))
    hm, cb
end

plot(hm, cb)

# %% [markdown]
# We can now obtain a QTT for `f` in the same way as in the 1D case:

# %%
# Construct 2D quantics
qtci, ranks, errors = quanticscrossinterpolate(Float64, f, grid)
χ = 1:length(qtci.tci.pivoterrors)
plot(χ, nextfloat(0.0) .+ qtci.tci.pivoterrors ./ qtci.tci.maxsamplevalue, xlabel=L"\chi", ylabel="Normalized error", yscale=:log10, ylims=(1e-8, 1e1), yticks=(10.0 .^ (-8:1:1)), legend=false)

# %% [markdown]
# Checking the error on the same slices as before, we see that the approximation is accurate everywhere:

# %%
# Function that evaluates log10 of the interplation error at (x, y)
function errflog10(x, y)
    i = origcoord_to_grididx(grid, (x, y))
    log10(nextfloat(0.0) + abs(f(grididx_to_origcoord(grid, i)...) - qtci(i)))
end

ε = 1e-10
myplotheatmap(errflog10, (-5, 5 - ε), (-5, 5 - ε), xlim_box=(0.25, 1.75), ylim_box=(1.25, 2.75))

# %%
myplotheatmap(errflog10, (0.25, 1.75), (1.25, 2.75), xlim_box=(0.94, 1.0), ylim_box=(1.84, 1.9))

# %%
myplotheatmap(errflog10, (0.94, 1.0), (1.84, 1.9), xlim_box=(0.97, 0.97 + 1e-7), ylim_box=(1.88, 1.88 + 1e-7))

# %%
xs = LinRange(0.97, 0.97 + 1e-7, 400)
ys = LinRange(1.88, 1.88 + 1e-7, 400)
heatmap(xs, ys, errflog10.(xs', ys))
xticks!([0.97, 0.97 + 0.9e-7], ["0.97", "0.97+1e-7"])
yticks!([1.88, 1.88 + 1e-7], ["1.88", "1.88" * "\n" * "+1e-7"])

# %%
println("Number of sampled points ", length(TCI.cachedata(qtci.quanticsfunction)))

# %%

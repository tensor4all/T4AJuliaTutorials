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
#     display_name: julia 1.10.2
#     language: julia
#     name: julia-1.10
# ---

# %% [markdown]
# # Quantics TCI of multivariate funciton
#

# %%
import TensorCrossInterpolation as TCI
import QuanticsGrids: DiscretizedGrid, origcoord_to_quantics, origcoord_to_grididx
using QuanticsTCI
using Plots
# pythonplot() # use pythonplot backend for plotting
using LaTeXStrings

# %% [markdown]
# ## Artificial function with widely different length scales
#

# %%
f(x, y) = (exp(-0.4 * (x^2 + y^2)) + 1 + sin(x * y) * exp(-x^2) +
           cos(3 * x * y) * exp(-y^2) + cos(x + y)) + 0.05 * cos(1 / 0.001 * (0.2 * x - 0.4 * y)) + 0.0005 * cos(1 / 0.0001 * (-0.2 * x + 0.7 * y)) + 1e-5 * cos(1 / 1e-7 * (20 * x))

R = 40
gr = DiscretizedGrid{2}(R, (-5, -5), (5, 5))

function plotbox!(p, xlim, ylim)
    plot!([xlim[1], xlim[2], xlim[2], xlim[1], xlim[1]], [ylim[1], ylim[1], ylim[2], ylim[2], ylim[1]], color=:lightgreen, lw=2, label="")
    p
end

function plotheatmap(func, xlim, ylim, xlim_box=nothing, ylim_box=nothing)
    xs = LinRange(xlim..., 400)
    ys = LinRange(ylim..., 400)
    p = heatmap(xs, ys, [func(x, y) for x in xs, y in ys], xlabel=L"x", ylabel=L"y", xtickfontsize=10, ytickfontsize=10,)
    if xlim_box !== nothing && ylim_box !== nothing
        plotbox!(p, xlim_box, ylim_box)
    end
    p
end

# %%
p = plotheatmap(f, (-5, 5), (-5, 5), (0.25, 1.75), (1.25, 2.75))
p

# %%
p = plotheatmap(f, (0.25, 1.75), (1.25, 2.75), (0.94, 1.0), (1.84, 1.9))
p

# %%
p = plotheatmap(f, (0.94, 1.0), (1.84, 1.9), (0.97, 0.97 + 1e-7), (1.88, 1.88 + 1e-7))
p

# %%
xs = LinRange(0.97, 0.97 + 1e-7, 400)
ys = LinRange(1.88, 1.88 + 1e-7, 400)
p = heatmap(xs, ys, f.(xs', ys), xlabel=L"x", ylabel=L"y",
    xticks=((0.97, 0.97 + 1e-7), ("0.97", "0.97+1e-7")),
    yticks=((1.88, 1.88 + 1e-7), ("1.88", "1.88+1e-7")), xtickfontsize=10, ytickfontsize=10)
p

# %%
# Construct 2D quantics
qtci, ranks, errors = quanticscrossinterpolate(Float64, f, gr)
p = plot(qtci.tt.pivoterrors ./ qtci.tt.maxsamplevalue, xaxis=L"\chi", yaxis="Normalized error", yscale=:log10, label="", xtickfontsize=10, ytickfontsize=10)
p

# %%
# Function that evaluates log10 of the interplation error at (x, y)
errflog10(x, y) = log10(abs(f(x, y) - qtci(origcoord_to_grididx(gr, (x, y)))))

eps = 1e-10
p = plotheatmap(errflog10, (-5, 5 - eps), (-5, 5 - eps), (0.25, 1.75), (1.25, 2.75))
p

# %%
p = plotheatmap(errflog10, (0.25, 1.75), (1.25, 2.75), (0.94, 1.0), (1.84, 1.9))
p

# %%
p = plotheatmap(errflog10, (0.94, 1.0), (1.84, 1.9), (0.97, 0.97 + 1e-7), (1.88, 1.88 + 1e-7))
p

# %%
xs = LinRange(0.97, 0.97 + 1e-7, 400)
ys = LinRange(1.88, 1.88 + 1e-7, 400)
p = heatmap(xs, ys, errflog10.(xs', ys), xlabel=L"x", ylabel=L"y",
    xticks=((0.97, 0.97 + 1e-7), ("0.97", "0.97+1e-7")),
    yticks=((1.88, 1.88 + 1e-7), ("1.88", "1.88+1e-7")), xtickfontsize=10, ytickfontsize=10)
p

# %% [markdown]
# ## Low-rank structure in Fourier transform matrix
#

# %%
import TensorCrossInterpolation as TCI
import QuanticsGrids as QD

R = 20 # R must be even

# 1D grid with 2^R points starting at 0
grid = QD.InherentDiscreteGrid{1}(R, 0)

# Fourier transform matrix
fkm(k::Int, m::Int) = exp(-2π * im * k * m / 2^R) / 2^(R ÷ 2)

function fq(fused_quantics_index::Vector{Int})
    # Compute quantics indices for k and m
    kq, mq = QD.unfuse_dimensions(fused_quantics_index, 2)
    reverse!(kq) # bit reversal
    return fkm(
        QD.quantics_to_origcoord(grid, kq),
        QD.quantics_to_origcoord(grid, mq)
    )
end

localdims = fill(2^2, R)
firstpivots = [ones(Int, R)]
qtci, ranks, errors = TCI.crossinterpolate2(ComplexF64, fq, localdims, firstpivots; tolerance=1e-8, verbosity=1, loginterval=1)

using Plots
# pythonplot() # use pythonplot backend for plotting
plot(qtci.pivoterrors, label="pivot errors", yaxis=:log)

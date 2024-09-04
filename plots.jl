# -*- coding: utf-8 -*-
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
#     display_name: Julia 1.10.5
#     language: julia
#     name: julia-1.10
# ---

# %% [markdown]
# # Plots.jl

# %%
using Plots
using Plots.RecipesBase: @recipe

# %%
# defines mutable struct `SemiLogy` and sets shorthands `semilogy` and `semilogy!`
@userplot SemiLogy
@recipe function f(t::SemiLogy)
    x = t.args[begin]
    y = t.args[end]
    ε = nextfloat(0.0)

    yscale := :log10
    # Warning: Invalid negative or zero value 0.0 found at series index 16 for log10 based yscale
    # prevent log10(0) from being -Inf
    (x, ε .+ y)
end

# %%
semilogy((-10:1:-7), 10.0 .^ (-10:1:-7))

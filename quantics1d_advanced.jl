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
# Click [here](https://gitlab.com/api/v4/projects/56283350/jobs/artifacts/main/raw/notebooks/quantics1d_advanced.ipynb?job=pages) to download the notebook locally.
#

# %% [markdown]
# # Quantics TCI of univariate funciton (advanced topics)
#

# %%
using PythonCall: PythonCall
using PythonPlot: pyplot as plt, Figure

# Displays the matplotlib figure object `fig` and avoids duplicate plots.
_display(fig::Figure) = isinteractive() ? (fig; plt.show(); nothing) : Base.display(fig)
_display(fig::PythonCall.Py) = _display(Figure(fig))

import QuanticsGrids as QG
import TensorCrossInterpolation as TCI

# %% [markdown]
# ## Example 1 (continuation)
#
# ### Performance tips
#
# Let's recall again the function $f(x)$ from the [previous page](quantics1d.md).
#
# $$
# f(x) = \cos\left(\frac{x}{B}\right) \cos\left(\frac{x}{4\sqrt{5}B}\right) e^{-x^2} + 2e^{-x},
# $$
#
# where $B = 2^{-30}$.
#
# In the [previous page](quantics1d.md), we implemented $f(x)$ as
#

# %% [markdown]
# ```julia
# B = 2^(-30) # global variable
# # This is simple, but not recommended
# function f(x)
#     return cos(x/B) * cos(x/(4*sqrt(5)*B)) * exp(-x^2) + 2 * exp(-x)
# end
# ```
#

# %% [markdown]
# However, since the implementation treats `B` as a untyped global variables, Julia compiler won't generate efficient code. See [Performance tips](https://docs.julialang.org/en/v1/manual/performance-tips/#Avoid-untyped-global-variables) at the official Julia documentatoin to learn more. In Julia, this can be written as below:
#

# %%
# Define callable struct
Base.@kwdef struct Ritter2024 <: Function
    B::Float64 = 2^(-30)
end

# Make Ritter2024 be "callable" object.
function (obj::Ritter2024)(x)
    B = obj.B
    return cos(x / B) * cos(x / (4 * sqrt(5) * B)) * exp(-x^2) + 2 * exp(-x)
end

f = Ritter2024()
nothing # hide

# %% [markdown]
# Such "callable" objects are sometimes called "functors." See [Function like objects](https://docs.julialang.org/en/v1/manual/methods/#Function-like-objects) at the official Julia documentation to learn more.
#

# %% [markdown]
# ### The inside work of `quanticscrossinterpolate`
#
# Let us see the inside work of the `quanticscrossinterpolate` function in `QuanticsTCI.jl` by implementing the previous example using `QuanticsGrids.jl` and `TensorCrossInterpolation.jl`.
#
# We first define a grid as in the previous example:
#

# %%
import QuanticsGrids as QG
using PythonPlot: pyplot as plt, gcf

R = 40 # number of bits
xmin = 0.0
xmax = 3.0
qgrid = QG.DiscretizedGrid{1}(R, xmin, xmax; includeendpoint=false)

# %% [markdown]
# We now define a function that takes a quantics index, which is named `qf`.
#

# %%
localdims = fill(2, R) # Sizes of local indices
qf(q) = f(QG.quantics_to_origcoord(qgrid, q))
cf = TCI.CachedFunction{Float64}(qf, localdims)

# %% [markdown]
# Here, we've defined a function `qf` that accepts quantics `q` as an argument. Then we wrap `qf` using `TCI.CachedFunction`.
# The function `QuanticsGrids.quantics_to_origcoord` converts a quantics index to a point (in this example, of type Float64) in the original coordinate system.
# `TCI.CachedFunction` caches function evaluations;
# `cf` caches the pair of input and output that are used during constructing a QTT representation.
# This is useful if a function evaluation takes more than 100 ns or if you want to record function evaluations.
#
# Choosing good initial pivots is critical for numerical stability.
# In the following code, we generate initial pivots by finding local maxima of $|f(x)|$. The function `optfirstpivot` maximizes the given function `qf` using single-index updates (zero-temperature Monte Calro).
#

# %%
nrandominitpivot = 5

# random initial pivot
initialpivots = [
        TCI.optfirstpivot(qf, localdims, [rand(1:d) for d in localdims]) for _ in 1:nrandominitpivot
]

qf.(initialpivots) # Function values at initial pivots

# %% [markdown]
# We are ready to construct a QTT representation of `cf` via `TCI.crossinterpolate2`:
#

# %%
ci, ranks, errors = TCI.crossinterpolate2(Float64, cf, localdims, initialpivots; maxbonddim=15)

# %% [markdown]
# You can retrieve the results of the function evaluations during the TCI construction as follows.
#

# %%
cache = TCI.cachedata(cf) # Dict{Vector{Int},Float64}

_qs = collect(keys(cache)) # quantics indices
_xs = QG.quantics_to_origcoord.(Ref(qgrid), _qs) # original coordinates
xs_evaluated = sort(_xs);

# %% [markdown]
# The object `xs_evaluated` stores points what we wanted to know.
#
# We expect `ci::TensorCrossInterpolation.TensorCI2{Float64}` approximates `cf`(and `f`):
# Just in case, we will check `qf` approximates `f` and `qf` and `cf` functions output the same result:
#

# %%
x = 0.2
# convert `x` in the original coordinate system to the corresponding `q` of quantics
q = QG.origcoord_to_quantics(qgrid, x)
println("f(x) = $(f(x)), qf(q) = $(qf(q)), cf(q) = $(cf(q)), ci(q) = $(ci(q))")

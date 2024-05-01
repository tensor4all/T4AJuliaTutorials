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
# Click [here](https://gitlab.com/api/v4/projects/56283350/jobs/artifacts/main/raw/notebooks/quantics1d.ipynb?job=pages) to download the notebook locally.
#

# %% [markdown]
# # Quantics TCI of univariate funciton
#

# %%
using PythonCall: PythonCall
using PythonPlot: pyplot as plt, Figure

# Displays the matplotlib figure object `fig` and avoids duplicate plots.
_display(fig::Figure) = isinteractive() ? (fig; plt.show(); nothing) : Base.display(fig)
_display(fig::PythonCall.Py) = _display(Figure(fig))

import QuanticsGrids as QG
using QuanticsTCI: quanticscrossinterpolate

# %% [markdown]
# ## Example 1
#
# The first example is taken from Fig. 1 in [Ritter2024](https://arxiv.org/abs/2303.11819).
#
# $$
# f(x) = \cos\left(\frac{x}{B}\right) \cos\left(\frac{x}{4\sqrt{5}B}\right) e^{-x^2} + 2e^{-x},
# $$
#
# where $B = 2^{-30}$. In Julia, this can be written as below:
#

# %%
B = 2^(-30) # global variable
function f(x)
    return cos(x / B) * cos(x / (4 * sqrt(5) * B)) * exp(-x^2) + 2 * exp(-x)
end

println(f(0.2))

# %% [markdown]
# Let's examine the behaviour of $f(x)$. This function involves structure on widely different scales: rapid, incommensurate oscillations and a slowly decaying envelope. We'll use [PythonPlot.jl](https://github.com/JuliaPy/PythonPlot.jl) visualisation library which uses Python library [matplotlib](https://matplotlib.org/) behind the scenes.
#
# For small $x$ we have:
#

# %%
xs = LinRange(0, 2.0^(-23), 1000)

fig, ax = plt.subplots()
ax.plot(xs, f.(xs), label="$(nameof(f))")
ax.set_title("$(nameof(f))")
ax.legend()
_display(fig)

# %% [markdown]
# For $x \in (0, 3]$ we will get:
#

# %%
xs2 = LinRange(2.0^(-23), 3, 100000)
fig, ax = plt.subplots()
ax.plot(xs2, f.(xs2), label="$(nameof(f))")
ax.set_title("$(nameof(f))")
ax.legend()
_display(fig)

# %% [markdown]
# ### QTT representation
#
# One can construct a QTT representation of this function on the domain $[0, 3]$ a quantics grid of size $2^\mathcal{R}$ where $\mathcal{R}$ is $40$:
#

# %%
R = 40 # number of bits
xmin = 0.0
xmax = 3.0
N = 2^R # size of the grid
# * Uniform grid (includeendpoint=false, default):
#   -xmin, -xmin+dx, ...., -xmin + (2^R-1)*dx
#     where dx = (xmax - xmin)/2^R.
#   Note that the grid does not include the end point xmin.
#
# * Uniform grid (includeendpoint=true):
#   -xmin, -xmin+dx, ...., xmin-dx, xmin,
#     where dx = (xmax - xmin)/(2^R-1).
qgrid = QG.DiscretizedGrid{1}(R, xmin, xmax; includeendpoint=false)
ci, ranks, errors = quanticscrossinterpolate(Float64, f, qgrid; maxbonddim=15)

# %% [markdown]
# Here, we've created `ci` which is an object of `QuanticsTensorCI2{Float64}` in `QuanticsTCI.jl`. This can be evaluated at an linear index $i$ ($1 \le i \le 2^\mathcal{R}$) as follows:
#

# %%
for i in [1, 2, 3, 2^R] # Linear indices
    # restore original coordinate `x` from linear index `i`
    x = QG.grididx_to_origcoord(qgrid, i)
    println("x: $(x), i: $(i), tci: $(ci(i)), ref: $(f(x))")
end

# %% [markdown]
# We see that `ci(i)` approximates the original `f` at `x = QG.grididx_to_origcoord(qgrid, i)`. Let's plot them together.
#

# %%
xs = LinRange(0, 2.0^(-23), 1000)
ys = f.(xs)

yci = map(xs) do x
    # Convert a coordinate in the original coordinate system to the corresponding grid index
    i = QG.origcoord_to_grididx(qgrid, x)
    ci(i)
end

fig, ax = plt.subplots()
ax.plot(xs, ys, label="$(nameof(f))")
ax.plot(xs, yci, label="tci", linestyle="dashed", alpha=0.7)
ax.set_title("$(nameof(f)) and TCI")
ax.set_xlabel("x")
ax.set_ylabel("y")
ax.legend()
_display(fig)

# %% [markdown]
# Above, one can see that the original function is interpolated very accurately.
#
# Let's plot of $x$ vs interpolation error $\log(|f(x) - \mathrm{ci}(x)|)$ for small $x$
#

# %%
fig, ax = plt.subplots()

xs = LinRange(0, 2.0^(-23), 1000)
ys = f.(xs)
yci = map(xs) do x
    # Convert a coordinate in the original coordinate system to the corresponding grid index
    i = QG.origcoord_to_grididx(qgrid, x)
    ci(i)
end

ax.plot(xs, log.(abs.(ys .- yci)), label="log(|f(x) - ci(x)|)")

ax.set_title("x vs interpolation error: $(nameof(f))")
ax.set_xlabel("x")
ax.set_ylabel("interpolation error")
ax.legend()
_display(fig)

# %% [markdown]
# ### About `ci::QuanticsTensorCI2{Float64}`
#
# Let's dive into the `ci` object:
#

# %%
println(typeof(ci))

# %% [markdown]
# As we've seen before, `ci` is an object of `QuanticsTensorCI2{Float64}` in `QuanticsTCI.jl`, which is a thin wrapper of `TensorCI2{Float64}` in `TensorCrossInterpolation.jl`.
# The undering object of `TensorCI2{Float64}` type can be accessed as `ci.tci`. This will be useful for obtaining more detailed information on the TCI results.
#
# For instance, `ci.tci.maxsamplevalue` is an estimate of the abosolute maximum value of the function, and `ci.tci.pivoterrors` stores the error as function of the bond dimension computed by prrLU.
# In the following figure, we plot the normalized error vs. bond dimension, showing an exponential decay.
#

# %%
# Plot error vs bond dimension obtained by prrLU
fig, ax = plt.subplots()
ax.plot(ci.tci.pivoterrors ./ ci.tci.maxsamplevalue, marker="x")
ax.set_xlabel("Bond dimension")
ax.set_ylabel("Normalization error")
ax.set_title("normalized error vs. bond dimension: $(nameof(f))")
ax.set_yscale("log")
_display(fig)

# %% [markdown]
# ### Function evaluations
#
# Our TCI algorithm does not call elements of the entire tensor, but constructs the TT (Tensor Train) from some elements chosen adaptively. On which points $x \in [0, 3]$ was the function evaluated to construct a QTT representation of the function $f(x)$? Let's find out. One can retrieve the information on the function evaluations as follows.
#

# %%
import QuanticsTCI
# Dict{Float64,Float64}
# key: `x`
# value: function value at `x`
evaluated = QuanticsTCI.cachedata(ci)

# %% [markdown]
# Let's plot `f` and the evaluated points together.
#

# %%
f̂(x) = ci(QG.origcoord_to_quantics(qgrid, x))
xs = LinRange(0, 2.0^(-23), 1000)

xs_evaluated = collect(keys(evaluated))
fs_evaluated = [evaluated[x] for x in xs_evaluated]

fig, ax = plt.subplots()
ax.plot(xs, f.(xs), label="$(nameof(f))")
ax.scatter(xs_evaluated, fs_evaluated, marker="x", label="evaluated points")
ax.set_title("$(nameof(f)) and TCI")
ax.set_xlabel("x")
ax.set_ylabel("y")
ax.set_xlim(0, maximum(xs))
ax.legend()
_display(fig)

# %% [markdown]
# ## Example 2
#
# We now consider the function:
#
# $$
# \newcommand{\sinc}{\mathrm{sinc}}
# \begin{align}
# f(x) &= \sinc(x)+3e^{-0.3(x-4)^2}\sinc(x-4) \nonumber\\
# &\quad - \cos(4x)^2-2\sinc(x+10)e^{-0.6(x+9)} + 4 \cos(2x) e^{-|x+5|}\nonumber \\
# &\quad +\frac{6}{x-11}+ \sqrt{(|x|)}\arctan(x/15).\nonumber
# \end{align}
# $$
#
# One can construct a QTT representation of this function on the domain $[-10, 10]$ using a quantics grid of size $2^\mathcal{R}$ ($\mathcal{R}=20$):
#

# %%
import QuanticsGrids as QG
using QuanticsTCI

R = 20 # number of bits
N = 2^R  # size of the grid

qgrid = QG.DiscretizedGrid{1}(R, -10, 10; includeendpoint=false)

# Function of interest
function oscillation_fn(x)
    return (
        sinc(x) + 3 * exp(-0.3 * (x - 4)^2) * sinc(x - 4) - cos(4 * x)^2 -
        2 * sinc(x + 10) * exp(-0.6 * (x + 9)) + 4 * cos(2 * x) * exp(-abs(x + 5)) +
        6 * 1 / (x - 11) + sqrt(abs(x)) * atan(x / 15))
end

# Convert to quantics format and sweep
ci, ranks, errors = quanticscrossinterpolate(Float64, oscillation_fn, qgrid; maxbonddim=15)

# %%
for i in [1, 2, 2^R] # Linear indices
    x = QG.grididx_to_origcoord(qgrid, i)
    println("x: $(x), tci: $(ci(i)), ref: $(oscillation_fn(x))")
end

# %% [markdown]
# Above, one can see that the original function is interpolated very accurately. The function `grididx_to_origcoord` transforms a linear index to a coordinate point $x$ in the original domain ($-10 \le x < 10$).
#
# In the following figure, we plot the normalized error vs. bond dimension, showing an exponential decay.
#

# %%
# Plot error vs bond dimension obtained by prrLU
using PythonPlot: pyplot as plt, gcf

fig, ax = plt.subplots()
ax.plot(ci.tci.pivoterrors ./ ci.tci.maxsamplevalue, marker="x")
ax.set_xlabel("Bond dimension")
ax.set_ylabel("Normalization error")
ax.set_title("normalized error vs. bond dimension")
ax.set_yscale("log")
_display(fig)

# %% [markdown]
# ## Example 3
#
# ### Control the error of the TCI by a tolerance
#
# We interpolate the same function as in Example 2, but this time we use a tolerance to control the error of the TCI. The tolerance is a positive number that determines the maximum error of the TCI, which is scaled by an estimate of the abosolute maximum of the function.
# The TCI algorithm will adaptively increase the bond dimension until the error is below the tolerance.

# %%
tol = 1e-8 # Tolerance for the error

# Convert to quantics format and sweep
ci_tol, ranks_tol, errors_tol = quanticscrossinterpolate(
    Float64, oscillation_fn, qgrid;
    tolerance=tol,
    normalizeerror=true, # Normalize the error by the maximum sample value,
    verbosity=1, loginterval=1, # Log the error every `loginterval` iterations
    )

# %%
println("Max abs sampled value is $(ci_tol.tci.maxsamplevalue)")

# %%
errors_tol ./ ci_tol.tci.maxsamplevalue

# %% [markdown]
# ### Estimate the error of the TCI
# Wait!
# Since we did not sample the function over the entire domain, we do not know the true error of the TCI.
# In theory, we can estimate the error of the TCI by comparing the function values at the sampled points with the TCI values at the same points.
# But, it is not practical to compare the function values with the TCI values at all points in the domain.
# The function `estimatetrueerror` in `TensorCrossInterpolation.jl` provides a good estimate of the error of the TCI.
# The algorithm finds indices (points) where the error is large by a randomized global search algorithm starting with a set of random initial points.

# %%
import TensorCrossInterpolation as TCI
pivoterror_global = TCI.estimatetrueerror(TCI.TensorTrain(ci.tci), ci.quanticsfunction; nsearch=100) # Results are sorted in descending order of the error

# %% [markdown]
# Now, you can see the error estimate of the TCI is below the tolerance of $10^{-8}$ (or close to it).

# %%
println("The largest error found is $(pivoterror_global[1][2]) and the corresponding pivot is $(pivoterror_global[1][1]).")
println("The tolenrance used is $(tol * ci_tol.tci.maxsamplevalue).")

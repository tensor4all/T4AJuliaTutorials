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
#     display_name: Julia 1.10.4
#     language: julia
#     name: julia-1.10
# ---

# %% [markdown]
# Click [here](https://tensor4all.org/T4AJuliaTutorials/_sources/ipynbs/qft.ipynb) to download the notebook locally.
#

# %% [markdown]
# # Quantum Fourier Transform
#

# %%
using PythonCall: PythonCall
using PythonPlot: pyplot as plt, Figure
using LaTeXStrings

# Displays the matplotlib figure object `fig` and avoids duplicate plots.
_display(fig::Figure) = isinteractive() ? (fig; plt.show(); nothing) : Base.display(fig)
_display(fig::PythonCall.Py) = _display(Figure(fig))

import QuanticsGrids as QG
import TensorCrossInterpolation as TCI
using QuanticsTCI: quanticscrossinterpolate, quanticsfouriermpo

# %% [markdown]
# ## 1D Fourier transform
#
# $$
# %\newcommand{\hf}{\hat{f}}   %Fourier transform of \bff
# %\newcommand{\hF}{\hat{F}}
# $$
#
#
# Consider a discrete function $f_m \in \mathbb{C}^M$, e.g. the 
# discretization, $f_m = f(x(m))$, of a one-dimensional function $f(x)$ on a grid $x(m)$. 
# Its discrete Fourier transform (DFT) is
#
# $$
# \hat{f}_k = \sum_{m=0}^{M-1}   T_{km} f_m , \qquad 
# T_{km} =  \tfrac{1}{\sqrt{M}}  e^{- i 2 \pi k \cdot m /M} .
# $$
#
# For a quantics grid, $M = 2^\mathcal{R}$ is exponentially large and the (naive) DFT exponentially expensive to evaluate.
# However, the QTT representation of $T$ is known to have a low-rank structure and can be represented as a tensor train with small bond dimensions.
#
# Thus, if the input function $f$ is given in the quantics representation as
#
# <img src="https://raw.githubusercontent.com/tensor4all/T4AJuliaTutorials/main/qft1.png" alt="qft1" width="30%">,
#
# $\hat{f} = T f$ can be computed by efficiently contracting the tensor trains for $T$ and $f$ and recompressing the result:
#
# <img src="https://raw.githubusercontent.com/tensor4all/T4AJuliaTutorials/main/qft2.png" alt="qft contraction" width="60%">.
#
# Note that after the Fourier transform, the quantics indices $\sigma_1,\cdots,\sigma_\mathcal{R}$ are ordered in the inverse order of the input indices $\sigma'_1,\cdots,\sigma'_\mathcal{R}$.
# This allows construction of the DFT operator with small bond dimensions.

# %% [markdown]
#
#
# We consider a function $f(x)$, which is the sum of exponential functions, defined on interval $[0,1]$:
#
# $$
# f(x) = \sum_p \frac{c_p}{1 - e^{-\epsilon_p}} e^{-\epsilon_p x}.
# $$
#
# Its Fourier transform is given by
#
# $$
# \hat{f}_k = \int_0^1 dx \, f(x) e^{i \omega_k x} = - \sum_p \frac{c_p}{i\omega_k - \epsilon_p}.
# $$
#
# for $k = 0, 1, \cdots $ and $\omega_k = 2\pi k$.
#
# If you are familiar with quantum field theory, you can think of $f(x)$ as a bosonic correlation function.

# %%
coeffs = [1.0, 1.0]
ϵs = [100.0, -50.0]

_exp(x, ϵ) = exp(-ϵ * x)/ (1 - exp(-ϵ))

fx(x) = sum(coeffs .* _exp.(x, ϵs))

# %%
plotx = range(0, 1; length=1000)

fig, ax = plt.subplots()

ax.plot(plotx, fx.(plotx))
ax.set_xlabel(L"x")
ax.set_ylabel(L"f(x)")
_display(fig)

# %% [markdown]
# First, we construct a QTT representation of the function $f(x)$.

# %%
R = 40
xgrid = QG.DiscretizedGrid{1}(R, 0, 1)

qtci, ranks, errors = quanticscrossinterpolate(Float64, fx, xgrid; tolerance=1e-10)

# %% [markdown]
# Second, we compute the Fourier transform of $f(x)$ using the QTT representation of $f(x)$ and the QTT representation of the DFT operator $T$:
#
# $$
# \hat{f}_k = \int_0^1 dx \, f(x) e^{i \omega_k x} \approx \frac{1}{M} \sum_{m=0}^{M-1} f_m e^{i 2 \pi k m / M} =  \frac{1}{\sqrt{M}} \sum_{m=0}^{M-1} T_{km} f_m.
# $$
#
# for $k = 0, \ldots, M-1$ and $\omega_k = 2\pi k$.
# This can be implemented as follows.

# %%
# Construct QTT representation of T_{km}
fouriertt = quanticsfouriermpo(R; sign=1.0, normalize=true)

# Apply T_{km} to the QTT representation of f(x)
sitedims = [[2,1] for _ in 1:R]
ftt = TCI.TensorTrain(qtci.tci)
hftt = TCI.contract(fouriertt, ftt; algorithm=:naive, tolerance=1e-8)

hftt *= 1/sqrt(2)^R

@show hftt
;

# %% [markdown]
# Let us compare the result with the exact Fourier transform of $f(x)$.

# %%
kgrid = QG.InherentDiscreteGrid{1}(R, 0) # 0, 1, ..., 2^R-1

_expk(k, ϵ) = -1 / (2π * k * im - ϵ)
hfk(k) = sum(coeffs .* _expk.(k, ϵs)) # k = 0, 1, 2, ..., 2^R-1

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

plotk = collect(0:300)
y = [hftt(reverse(QG.origcoord_to_quantics(kgrid, x))) for x in plotk] # Note: revert the order of the quantics indices

ax1.plot(plotk, real.(y), marker="+", label="QFT")
ax1.plot(plotk, real.(hfk.(plotk)), marker="x", label="Reference")
ax1.set_xlabel(L"k")
ax1.set_ylabel(L"\mathrm{Re}~\hat{f}(k)")
ax1.legend()

ax2.plot(plotk, imag.(y), marker="+", label="QFT")
ax2.plot(plotk, imag.(hfk.(plotk)), marker="x", label="Reference")
ax2.set_xlabel(L"k")
ax2.set_ylabel(L"\mathrm{Im}~\hat{f}(k)")
ax2.legend()

_display(fig)

# %% [markdown]
# The exponentially large quantics grid allows to compute the Fourier transform with high accuracy at high frequencies.
# To check this, let us compare the results at high frequencies.

# %%
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

plotk = [10^n for n in 1:5]
@assert maximum(plotk) <= 2^R-1
y = [hftt(reverse(QG.origcoord_to_quantics(kgrid, x))) for x in plotk] # Note: revert the order of the quantics indices

ax1.loglog(plotk, abs.(real.(y)), marker="+", label="QFT")
ax1.loglog(plotk, abs.(real.(hfk.(plotk))), marker="x", label="Reference")
ax1.set_xlabel(L"k")
ax1.set_ylabel(L"\mathrm{Re}~\hat{f}(k)")
ax1.legend()

ax2.loglog(plotk, abs.(imag.(y)), marker="+", label="QFT")
ax2.loglog(plotk, abs.(imag.(hfk.(plotk))), marker="x", label="Reference")
ax2.set_xlabel(L"k")
ax2.set_ylabel(L"\mathrm{Im}~\hat{f}(k)")
ax2.legend()

_display(fig)

# %% [markdown]
# You may use ITensors.jl to compute the Fourier transform of the function $f(x)$.
# The following code explains how to do this.

# %%
import TCIITensorConversion
using ITensors
import Quantics: fouriertransform, Quantics

sites_m = [Index(2, "Qubit,m=$m") for m in 1:R]
sites_k = [Index(2, "Qubit,k=$k") for k in 1:R]

fmps = MPS(ftt; sites=sites_m)

# Apply T_{km} to the MPS representation of f(x) and reply the result by 1/sqrt(M)
# tag="m" is used to indicate that the MPS is in the "m" basis.
hfmps = (1/sqrt(2)^R) * fouriertransform(fmps; sign=1, tag="m", sitesdst=sites_k)

# %%
# Evaluate Ψ for a given index
_evaluate(Ψ::MPS, sites, index::Vector{Int}) = only(reduce(*, Ψ[n] * onehot(sites[n] => index[n]) for n in 1:length(Ψ)))

# %%
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 4))

plotk = [10^n for n in 1:5]
@assert maximum(plotk) <= 2^R-1
y = [_evaluate(hfmps, reverse(sites_k), reverse(QG.origcoord_to_quantics(kgrid, x))) for x in plotk] # Note: revert the order of the quantics indices

ax1.loglog(plotk, abs.(real.(y)), marker="+", label="QFT")
ax1.loglog(plotk, abs.(real.(hfk.(plotk))), marker="x", label="Reference")
ax1.set_xlabel(L"k")
ax1.set_ylabel(L"\mathrm{Re}~\hat{f}(k)")
ax1.legend()

ax2.loglog(plotk, abs.(imag.(y)), marker="+", label="QFT")
ax2.loglog(plotk, abs.(imag.(hfk.(plotk))), marker="x", label="Reference")
ax2.set_xlabel(L"k")
ax2.set_ylabel(L"\mathrm{Im}~\hat{f}(k)")
ax2.legend()

_display(fig)

# %% [markdown]
# ## 2D Fourier transform
#
# We now consider a two-dimensional function $f(x, y) = \frac{1}{(1 - e^{-\epsilon})(1 - e^{-\epsilon'})} e^{-\epsilon x - \epsilon' y}$ defined on the interval $[0,1]^2$.
#
# Its Fourier transform is given by
#
# $$
# \hat{f}_{kl} = \int_0^1  \int_0^1 dx dy \, f(x, y) e^{i \omega_k x + i\omega_l y} \approx \frac{1}{M^2} \sum_{m,n=0}^{M-1} f_{mn} e^{i 2 \pi (k m + l n) / M} =  \frac{1}{M} \sum_{m,n=0}^{M-1} T_{km} T_{ln} f_{mn}.
# $$
#
# The exact form of the Fourier transform is
#
# $$
# \hat{f}_{kl} = \frac{1}{(i\omega_k - \epsilon) (i\omega_l - \epsilon')}.
# $$
#
# for $k, l = 0, 1, \cdots $, $\omega_k = 2\pi k$ and $\omega_l = 2\pi l$.
#
# The 2D Fourier transform can be numerically computed in QTT format (with interleaved representation) in a straightforward way using Quantics.jl.
#

# %%
ϵ = 1.0
ϵprime = 2.0
fxy(x, y) = _exp(x, ϵ) * _exp(y, ϵprime)

# 2D quantics grid using interleaved unfolding scheme
xygrid = QG.DiscretizedGrid{2}(R, (0, 0), (1, 1); unfoldingscheme=:interleaved)

# Resultant QTT representation of f(x, y) has bond dimension of 1.
qtci_xy, ranks_xy, errors_xy = quanticscrossinterpolate(Float64, fxy, xygrid; tolerance=1e-10)

# %%
# for discretizing `y`
sites_n = [Index(2, "Qubit,n=$n") for n in 1:R]

sites_l = [Index(2, "Qubit,l=$l") for l in 1:R]

sites_mn = collect(Iterators.flatten(zip(sites_m, sites_n)))

fmps2 = MPS(TCI.TensorTrain(qtci_xy.tci); sites=sites_mn)
siteinds(fmps2)

# %%
# Fourier transform for x
tmp_ = (1/sqrt(2)^R) * fouriertransform(fmps2; sign=1, tag="m", sitesdst=sites_k, cutoff=1e-20)

# Fourier transform for y
hfmps2 = (1/sqrt(2)^R) * fouriertransform(tmp_; sign=1, tag="n", sitesdst=sites_l, cutoff=1e-20)

siteinds(hfmps2)

# %% [markdown]
# For convinience, we swap the order of the indices.
#

# %%
# Convert to fused representation and swap the order of the indices
hfmps2_fused = MPS(reverse([hfmps2[2*n-1] * hfmps2[2*n] for n in 1:R]))

# From fused to interleaved representation
sites_kl = collect(Iterators.flatten(zip(sites_k, sites_l)))
hfmps2_reverse = Quantics.rearrange_siteinds(hfmps2_fused, [[x] for x in sites_kl])
siteinds(hfmps2_reverse)

# %%
fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(15, 4))

klgrid = QG.InherentDiscreteGrid{2}(R, (0, 0); unfoldingscheme=:interleaved)

sparse1dgrid = collect(0:4)

reconstdata = [
    _evaluate(hfmps2_reverse, sites_kl, QG.origcoord_to_quantics(klgrid, (k, l)))
    for k in sparse1dgrid, l in sparse1dgrid]

hfkl(k::Integer, l::Integer) = _expk(k, ϵ) * _expk(l, ϵprime)

exactdata = [hfkl(k, l) for k in sparse1dgrid, l in sparse1dgrid]

c = ax1.pcolor(real.(exactdata))
fig.colorbar(c, ax=ax1)
ax1.set_xlabel(L"k")
ax1.set_ylabel(L"l")
ax1.set_title("Real part of Exact data")

c = ax2.pcolor(real.(reconstdata))
fig.colorbar(c, ax=ax2)
ax2.set_xlabel(L"k")
ax2.set_ylabel(L"l")
ax2.set_title("Real part of Reconstructed data")

c = ax3.pcolor(abs.(exactdata .- reconstdata))
fig.colorbar(c, ax=ax3)
ax3.set_xlabel(L"k")
ax3.set_ylabel(L"l")
ax3.set_title("Error")

_display(fig)

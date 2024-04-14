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
# # PythonPlot
#
# [JuliaPy/PythonPlot.jl](https://github.com/JuliaPy/PythonPlot.jl) provides a Julia interface to the [Matplotlib](https://matplotlib.org/) plotting library from Python, and specifically to the matplotlib.pyplot module. This may be helpful for those who are new to Julia and come from Python.
#
# Consider that we have source code written in Python for plotting data like below:
#
# ```python
# from matplotlib import pyplot as plt
#
# fig, ax = plt.subplots()
# x = [1,2,3]
# y = [3,1,2]
# ax.plot(x, y, marker="+")
# ```
#
# With PythonPlot, porting this code to Julia is as simple as replacing the line `from matplotlib import pyplot as plt` with:
#
# ```julia
# using PythonPlot: pyplot as plt
# ```
#
# This allows us to use the familiar "plt syntax" within your Julia code.
#
# ```julia
# using PythonPlot: pyplot as plt
#
# fig, ax = plt.subplots()
# x = [1,2,3]
# y = [3,1,2]
# ax.plot(x, y, marker="+")
# ```
#

# %% [markdown]
# ## Better plot handling
#
# As explained above, PythonPlot facilitates a smooth transition from Python to Julia for data visualization tasks. In this section, we provide valuable tips and tricks for experimenting with Julia and Jupyter Notebook or VS Code.
#

# %%
using PythonPlot: pyplot as plt

fig, ax = plt.subplots()
x = [1, 2, 3]
y = [3, 1, 2]
ax.plot(x, y, marker="+")

# %%

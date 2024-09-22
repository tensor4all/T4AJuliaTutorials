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
# # Developer guide
#
# This page explains how to set up a development environment for building the [tensor4all Julia Tutorials page](https://tensor4all.org/T4AJuliaTutorials/ipynbs/index.html) locally. The source code can be obtained from our Git repository:
#
# https://github.com/tensor4all/T4AJuliaTutorials
#

# %% [markdown]
# ## Prerequisites
#
# To build our tutorials locally, you will need to install the following general-purpose software:
#
# - Install Git (`git`)
# - Install Julia (`julia`)
# - Install GNU Make (`make`)
#
#
# Our [T4AJuliaTutorials/Wiki](https://github.com/tensor4all/T4AJuliaTutorials/wiki) provides step-by-step installation guides for each operating system, including Windows, macOS, WSL2, and Linux. While we provide an installation guide on Windows, Jupyter Book has some limitations on it; see the [Jupyter Book documentation: Working on Windows](https://jupyterbook.org/en/stable/advanced/windows.html) for more information.
#
#
#

# %% [markdown]
# ## Clone this repository
#
# The following commands clones(downloads) our source code for T4AJuliaTutorials:
#
# ```sh
# $ cd path/to/your/workspace/directory
# $ git clone https://github.com/tensor4all/T4AJuliaTutorials.git
# ```
#
# Use `cd T4AJuliaTutorials` to navigate the `T4AJuliaTutorials` directory:
#
# ```sh
# $ cd T4AJuliaTutorials
# ```
#
# The `ls` command lists the files under the `T4AJuliaTutorials` directory:
#
# ```sh
# $ ls
# CondaPkg.toml README.md index.jl Makefile Project.toml scripts ...
# ```

# %% [markdown]
# ## Build T4AJuliaTutorials
#
# Just run `make` command:
#
# ```sh
# $ make
# ```
#
# ### What does `make` do behind the scenes?
#
# The `make` command runs operations according to the instructions in `Makefile`. We invoke `scripts/setup.jl`, which resolves dependencies related to Julia and installs a Python environment using [CondaPkg.jl](https://github.com/JuliaPy/CondaPkg.jl), which in turn runs [micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html) behind the scenes. The Python environment is stored in `.CondaPkg` within the root directory of our repository.
#
# In continuing to set up our Python environment, we install jupytext and `jupyter-book` in the Python environment stored in `.CondaPkg`. This operation will not pollute the Global Python Installation. If you encounter trouble with Python, try manually removing the `.CondaPkg` directory and then running the `make` command again.
#
# Next, we use `script/jupytext.jl` to invoke `jupytext --to ipynb --set-kernel=julia-1.10 <file>.jl --output ipynbs/<file>.ipynb` to convert notebooks in the form of Julia scripts `.jl` to ipynb format `.ipynb`.
#
# Finally, we use `script/jupyter_book.jl` to invode `jupyter-book build .` command. This will build our page on your computer.

# %% [markdown]
# You will find `_build/html/index.html` is generated. Open this file in a browser to confirm our Jupyter Book is generated properly.

# %% [markdown]
# ## Clean up
#
# Just run:
#
# ```sh
# $ make clean
# ```

# %% [markdown]
# ## Contributing
#
# ### Why do we store `jl` files rather than `ipynb` files?
#
# We do not want to commit in `ipynb` files, which are difficult for humans to read and could contain binary data. Instead, we commit files as `jl` which can be transformed into ipynb format via `jupytext`.
#
# ### Edit source files from VS Code
#
# If you are familiar with using VS Code, you could use `code` command from your terminal. To install required extensions for our workflow, run the following command:
#
# ```sh
# $ code --install-extension ms-toolsai.jupyter 
# $ code --install-extension julialang.language-julia  
# $ code --install-extension congyiwu.vscode-jupytext
# ```
#
# Open VS Code by runnning
#
# ```sh
# $ cd /path/to/this/repository
# $ code .
# ```
#
# On the left side of the workspace you can see the source files in `.jl` which will be converted to ipynb when building Jupyter Book for our project. To edit files Open a file, for example `quantics1d.jl` with a right click. Select `Open as Jupyter Notebook` to edit the file in Jupyter Notebook format. The `congyiwu.vscode-jupytext` extension allows us to synchronize the Jupyter Notebook file and the jl format file. Namely, if you edit a file of `ipynb`, the `jl` file corresponding to `ipynb` will be updated.
#
# See [T4AJuliaTutorials/Wiki](https://github.com/tensor4all/T4AJuliaTutorials/wiki) to learn more
#
# ### Edit source files from Web
#
# For those who want to edit files via Jupyter Notebook/Lab's client, run the following command:
#
# ```sh
# $ julia --project scripts/jupytext_config.jl
# $ julia --project -e 'using IJulia; IJulia.jupyterlab(dir=pwd())'
# install Jupyter via Conda, y/n? [y]: y # press y
# ```
#
# JupyterLab will be launched automatically. If you are familiar with Python, just run the command below:
#
# ```sh
# $ pip3 install jupytext jupyterlab
# $ jupytext-config set-default-viewer
# $ jupyter lab
# ```
#
# Here running `jupytext-config set-default-viewer` allows us to render jl files as Jupyter Notebook format. [See jupytext manual](https://jupytext.readthedocs.io/en/latest/text-notebooks.html#with-a-double-click) to learn more.
#
# By Clicking `quantics1d.jl` it will be converted to `quantics1d.ipynb` and Jupyter server will open `quantics1d.ipynb`. We are allowed to synchronize the Jupyter Notebook file and the jl format file.
#
# If your JupyterLab client can't treat `.jl` files as notebooks, try the following commands to convert `.jl` files to `.ipynb` files:
#
# ```sh
# $ julia --project scripts/jupytext.jl quantics1d.jl
# ```
#
# Internally `scripts/jupytext.jl` calls `jupytext` commands installed by Python managed by CondaPkg.jl/PythonCall.jl
#
# ### Update Project.toml and Manifest.toml together
#
# If one wants to update dependencies in `Project.toml`, please update `Manifest.toml` together. [This link](https://pkgdocs.julialang.org/v1/toml-files/#Manifest.toml) explains what Manifest.toml is:
#
# > The manifest file is an absolute record of the state of the packages in the environment. It includes exact information about (direct and indirect) dependencies of the project. Given a Project.toml + Manifest.toml pair, it is possible to instantiate the exact same package environment, which is very useful for reproducibility.
#

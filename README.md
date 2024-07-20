# T4AJuliaTutorials

This repository provides source files for building JupyterBook, which explains how to use packages registered in tensor4all organization.

## Prerequisites

- Install Git (`git`)
- Install Julia (`julia`)
- Install GNU Make (`make`)

### Clone this repository

```sh
$ cd path/to/your/workspace/directory
$ git clone https://github.com/tensor4all/T4AJuliaTutorials.git
$ cd T4AJuliaTutorials
```

## How to build a Jupyter Book

Just run `make` command:

```sh
$ ls
CondaPkg.toml README.md index.jl Makefile ... Project.toml
$ make
```

Then we will get outputs as below:

```
julia --project scripts/jupytext.jl interfacingwithitensors.jl
    CondaPkg Found dependencies: ~/work/T4AJuliaTutorials/CondaPkg.toml
    CondaPkg Found dependencies: ~/.julia/packages/PythonCall/bb3ax/CondaPkg.toml
    CondaPkg Found dependencies: ~/.julia/packages/PythonPlot/f591M/CondaPkg.toml
    CondaPkg Dependencies already up to date
[jupytext] Reading interfacingwithitensors.jl in format jl
[jupytext] Setting kernel julia-1.10
[jupytext] Updating notebook metadata with '{"kernelspec": {"name": "julia-1.10", "language": "julia", "display_name": "Julia 1.10.2"}}'
[jupytext] Writing ipynbs/interfacingwithitensors.ipynb (destination file replaced [use --update to preserve cell outputs and ids])
julia --project scripts/jupyter_book.jl
Running Jupyter-Book v1.0.0
...
...
...
writing additional pages... search done
copying images... [ 14%] _build/jupyter_execute/be1f99ce1077b1647e50b2f08
copying images... [ 29%] _build/jupyter_execute/7aa60660b8255c884e2161d94
copying images... [ 43%] _build/jupyter_execute/083314408bcee871cc804aaa2
copying images... [ 57%] _build/jupyter_execute/3ea4eb256bb802a9ddbc68d12
copying images... [ 71%] _build/jupyter_execute/8fbf08bfdb19e3830535aed88
copying images... [ 86%] _build/jupyter_execute/d4fa9a27b9cb8469ab97c9790
copying images... [100%] _build/jupyter_execute/1bbf71e3285bcd1ea04054810a8b1af59e3ee8321a4f74108637e95eac2c1c50.svg
dumping search index in English (code: en)... done
dumping object inventory... done
build succeeded, 4 warnings.

The HTML pages are in _build/html.

===============================================================================

Finished generating HTML for book.
Your book's HTML pages are here:
    _build/html/
You can look at your book by opening this file in a browser:
    _build/html/index.html
Or paste this line directly into your browser bar:
    ./T4AJuliaTutorials/_build/html/index.html

===============================================================================
```

You will find `_build/html/index.html` is generated. Open this file in a browser to confirm our Jupyter Book is generated properly.

## Clean up

Just run:

```sh
$ make clean
```

## Contributing

We do not want to commit in `ipynb` files, which are difficult for humans to read and could contain binary data. Instead, we commit files as `jl` which can be transformed into ipynb format via `jupytext`.

### Edit source files from VS Code

If you are familiar with using VS Code, you could use `code` command from your terminal. To install required extensions for our workflow, run the following command:

```sh
$ code --install-extension ms-toolsai.jupyter julialang.language-julia congyiwu.vscode-jupytext
```

Open VS Code by runnning

```
$ cd /path/to/this/repository
$ code .
```

On the left side of the workspace you can see the source files in `.jl` which will be converted to ipynb when building Jupyter Book for our project. To edit files Open a file, for example `quantics1d.jl` with a right click. Select `Open as Jupyter Notebook` to edit the file in Jupyter Notebook format. The `congyiwu.vscode-jupytext` extension allows us to synchronize the Jupyter Notebook file and the jl format file. Namely, if you edit a file of `ipynb`, the `jl` file corresponding to `ipynb` will be updated.

### Edit source files from Web

For those who want to edit files via Jupyter Notebook/Lab's client, run the following command:

```sh
$ julia --project scripts/jupytext_config.jl
$ julia --project -e 'using IJulia; IJulia.jupyterlab(dir=pwd())'
install Jupyter via Conda, y/n? [y]: y # press y
```

JupyterLab will be launched automatically. If you are familiar with Python, just run the command below:

```sh
$ pip3 install jupytext jupyterlab
$ jupytext-config set-default-viewer
$ jupyter lab
```

Here running `jupytext-config set-default-viewer` allows us to render jl files as Jupyter Notebook format. [See jupytext manual](https://jupytext.readthedocs.io/en/latest/text-notebooks.html#with-a-double-click) to learn more.

By Clicking `quantics1d.jl` it will be converted to `quantics1d.ipynb` and Jupyter server will open `quantics1d.ipynb`. We are allowed to synchronize the Jupyter Notebook file and the jl format file.

If your JupyterLab client can't treat `.jl` files as notebooks, try the following commands to convert `.jl` files to `.ipynb` files:

```sh
$ julia --project scripts/jupytext.jl quantics1d.jl
```

Internally `scripts/jupytext.jl` calls `jupytext` commands installed by Python managed by CondaPkg.jl/PythonCall.jl

### Update Project.toml and Manifest.toml together

If one wants to update dependencies in `Project.toml`, please update `Manifest.toml` together. [This link](https://pkgdocs.julialang.org/v1/toml-files/#Manifest.toml) explains what Manifest.toml is:

> The manifest file is an absolute record of the state of the packages in the environment. It includes exact information about (direct and indirect) dependencies of the project. Given a Project.toml + Manifest.toml pair, it is possible to instantiate the exact same package environment, which is very useful for reproducibility.

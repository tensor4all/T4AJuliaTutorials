using Conda

jupytext_config = joinpath(Conda.SCRIPTDIR, "jupytext-config")

run(`$(jupytext_config) set-default-viewer`)

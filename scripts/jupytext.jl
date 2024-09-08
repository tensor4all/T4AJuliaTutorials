using Conda
python = joinpath(Conda.PYTHONDIR, "python")

for jlfile in ARGS
	destination = joinpath("ipynbs", splitext(jlfile)[begin] * ".ipynb")
	run(`$(python) -m jupytext --to ipynb --set-kernel=julia-$(VERSION.major).$(VERSION.minor) $(jlfile) --output $(destination)`)
end

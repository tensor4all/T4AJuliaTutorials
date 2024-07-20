ipynbs/%.ipynb: %.jl
	julia --project scripts/setup.jl
	julia --project scripts/jupytext.jl $^

.PHONY: all
all: ipynbs/*.ipynb
	julia --project scripts/jupyter_book.jl

.PHONY: clean
clean:
ifeq ($(OS),Windows_NT)
	powershell Remove-Item ./ipynbs/*.ipynb
	powershell if (Test-Path _build) {Remove-Item -Recurse _build}
	powershell if (Test-Path .CondaPkg) {Remove-Item -Recurse .CondaPkg}
	powershell if (Test-Path default.profraw) {Remove-Item -Recurse default.profraw}
else
	-$(RM) ./ipynbs/*.ipynb
	-$(RM) -r ./_build
	-$(RM) -r .CondaPkg
	-$(RM) default.profraw
endif
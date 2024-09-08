ipynbs/%.ipynb: %.jl
	julia --project scripts/jupytext.jl $^

.PHONY: all
all: setup ipynbs/*.ipynb
	julia --project scripts/jupyter_book.jl

.PHONY: setup
setup:
	julia --project scripts/setup.jl

.PHONY: clean
clean:
ifeq ($(OS),Windows_NT)
	powershell Remove-Item ./ipynbs/*.ipynb
	powershell if (Test-Path _build) {Remove-Item -Recurse _build}
else
	-$(RM) ./ipynbs/*.ipynb
	-$(RM) -r ./_build
endif

ipynbs/%.ipynb: %.jl
	julia --project scripts/jupytext.jl $^

.PHONY: all
all: ipynbs/*.ipynb
	julia --project scripts/jupyter_book.jl

.PHONY: clean
clean:
	$(RM) ipynbs/*.ipynb
	$(RM) -r _build
	$(RM) default.profraw

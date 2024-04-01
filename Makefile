%.ipynb: %.jl
	#jupytext --to ipynb --set-kernel=julia-1.10 $^
	julia --project scripts/jupytext.jl $^

.PHONY: all
all: *.ipynb
	julia --project scripts/jupyter_book.jl

.PHONY: clean
clean:
	$(RM) *.ipynb
	$(RM) -r _build

FROM julia:1.10.2

RUN apt-get update && apt-get install -y --no-install-recommends make

ENV JULIA_PROJECT=@.
ENV PATH=$PATH:$HOME/.rye/shims

RUN curl -sSf https://rye-up.com/get | RYE_VERSION="0.32.0" RYE_INSTALL_OPTION="--yes" bash
RUN $HOME/.rye/shims/rye config --set-bool behavior.use-uv=true

RUN $HOME/.rye/shims/rye tools install jupytext \
	&& $HOME/.rye/shims/rye tools install ruff

COPY Project.toml /workspaces/T4FExamples/
RUN julia --project=/workspaces/T4FExamples/ -e 'using Pkg; Pkg.instantiate()' \
	&& julia --project=/workspaces/T4FExamples -e 'using Pkg; Pkg.build("IJulia")'

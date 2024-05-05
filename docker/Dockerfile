FROM julia:1.10.3

RUN apt-get update && apt-get install -y --no-install-recommends \
	make \
	git \
	&& apt-get clean && rm -rf /var/lib/apt/lists/*

ENV JULIA_PROJECT=@.
ENV PATH=$PATH:$HOME/.rye/shims

# Create user named jovyan which is compatible with Binder
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

RUN mkdir -p /workspaces/
RUN chown -R ${NB_UID} /workspaces/
USER ${NB_USER}

# https://rye-up.com/guide/installation/
RUN curl -sSf https://rye-up.com/get | RYE_VERSION="0.32.0" RYE_INSTALL_OPTION="--yes" bash
RUN $HOME/.rye/shims/rye config --set-bool behavior.use-uv=true

# https://jupytext.readthedocs.io/en/latest/index.html
RUN $HOME/.rye/shims/rye tools install jupytext \
	&& $HOME/.rye/shims/rye tools install ruff


USER root
COPY Project.toml /workspaces/T4FExamples/
RUN chown -R ${NB_UID} /workspaces/T4FExamples
USER ${NB_USER}

RUN julia --project=/workspaces/T4FExamples/ -e 'using Pkg; Pkg.instantiate()' \
	&& julia --project=/workspaces/T4FExamples -e 'using Pkg; Pkg.build("IJulia")'

# ## Features of this Dockerfile
#
# - Not based on devcontainer; use by attaching VSCode to the container
#   - https://code.visualstudio.com/docs/devcontainers/attach-container
# - Assumes host OS is Mac
#
# ## Preparation
#
# ### Download the files required to build the Docker container
#
#   curl -L -O https://raw.githubusercontent.com/uraitakahito/hello_python_uv/refs/heads/main/Dockerfile
#   curl -L -O https://raw.githubusercontent.com/uraitakahito/hello_python_uv/refs/heads/main/docker-entrypoint.sh
#   chmod 755 docker-entrypoint.sh
#
# ## Build the Docker image:
#
#   PROJECT=$(basename `pwd`) && docker image build -t $PROJECT-image . --build-arg user_id=`id -u` --build-arg group_id=`id -g`
#
# ## Create a volume to persist the command history executed inside the Docker container:
#
# It is stored in the volume because the dotfiles configuration redirects the shell history there.
# https://github.com/uraitakahito/dotfiles/blob/89b0c733d20b1c8b30ff55639d918259220f7765/config/zsh/conf.d/05-platform.zsh#L82-L91
#
#   docker volume create $PROJECT-zsh-history
#
# ## Run the Docker container:
#
# Start the Docker container(/run/host-services/ssh-auth.sock is a virtual socket provided by Docker Desktop for Mac.):
#
#   docker container run -d --rm --init -v /run/host-services/ssh-auth.sock:/run/host-services/ssh-auth.sock -e SSH_AUTH_SOCK=/run/host-services/ssh-auth.sock -e GH_TOKEN=$(gh auth token) --mount type=bind,src=`pwd`,dst=/app --mount type=volume,source=$PROJECT-zsh-history,target=/zsh-volume --name $PROJECT-container $PROJECT-image
#
# and log into the container.
#
# Only for the first startup, change the owner of the command history folder:
#
#   sudo chown -R $(id -u):$(id -g) /zsh-volume
#
# Run the following commands inside the Docker containers as needed:
#
#   uv run scripts/hello-numpy.py
#   uv run pytest
#
# ## Connect from Visual Studio Code
#
# 1. Open **Command Palette (Shift + Command + p)**
# 2. Select **Dev Containers: Attach to Running Container**
# 3. Open the `/app` directory
#

# Debian 12.13
FROM debian:bookworm-20260112

ARG user_name=developer
ARG user_id
ARG group_id
ARG dotfiles_repository="https://github.com/uraitakahito/dotfiles.git"
ARG features_repository="https://github.com/uraitakahito/features.git"
ARG extra_utils_repository="https://github.com/uraitakahito/extra-utils.git"
ARG python_variant=3.13

#
# Git
#
RUN apt-get update -qq && \
  apt-get install -y -qq --no-install-recommends \
    ca-certificates \
    git && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

#
# clone features
#
RUN cd /usr/src && \
  git clone --depth 1 ${features_repository}

#
# Add user and install common utils.
#
RUN USERNAME=${user_name} \
  USERUID=${user_id} \
  USERGID=${group_id} \
  CONFIGUREZSHASDEFAULTSHELL=true \
  UPGRADEPACKAGES=false \
  # When using ssh-agent inside Docker, add the user to the root group
  # to ensure permission to access the mounted socket.
  #   https://github.com/uraitakahito/features/blob/59e8acea74ff0accd5c2c6f98ede1191a9e3b2aa/src/common-utils/main.sh#L467-L471
  ADDUSERTOROOTGROUP=true \
    /usr/src/features/src/common-utils/install.sh

#
# Install extra utils.
#
RUN cd /usr/src && \
  git clone --depth 1 ${extra_utils_repository} && \
  ADDEZA=true \
  ADDGRPCURL=true \
  UPGRADEPACKAGES=false \
    /usr/src/extra-utils/utils/install.sh

#
# Install uv
# https://docs.astral.sh/uv/guides/integration/docker/#installing-uv
#
RUN curl --fail-early --silent --show-error --location https://astral.sh/uv/install.sh --output /tmp/uv-install.sh && \
  # Changing the install path
  # https://github.com/astral-sh/uv/blob/main/docs/configuration/installer.md#changing-the-install-path
  UV_INSTALL_DIR=/bin sh /tmp/uv-install.sh && \
  rm /tmp/uv-install.sh

COPY docker-entrypoint.sh /usr/local/bin/

USER ${user_name}

#
# Install Python
#
RUN uv python install ${python_variant}

#
# dotfiles
#
RUN cd /home/${user_name} && \
  git clone --depth 1 ${dotfiles_repository} && \
  dotfiles/install.sh

#
# Claude Code
#
# Discussion about using nvm during Docker container build:
#   https://stackoverflow.com/questions/25899912/how-to-install-nvm-in-docker
#
RUN curl -fsSL https://claude.ai/install.sh | bash

WORKDIR /app
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["tail", "-F", "/dev/null"]

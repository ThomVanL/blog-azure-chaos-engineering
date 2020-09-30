ARG TAG="4.6.1"
FROM mcr.microsoft.com/azure-powershell:${TAG}

# Options for setup script
ARG INSTALL_ZSH="true"
ARG UPGRADE_PACKAGES="false"
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

COPY common.sh /tmp/library-scripts/
RUN /bin/bash /tmp/library-scripts/common.sh "${INSTALL_ZSH}" "${USERNAME}" "${USER_UID}" "${USER_GID}" "${UPGRADE_PACKAGES}"

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get install -y \
    python3 \
    python3-venv \
    python3-pip \
    python3-setuptools \
    texlive-latex-base \
    texlive-fonts-recommended \
    texlive-latex-extra \
    curl && \
    curl -Lsf -o pandoc.deb https://github.com/jgm/pandoc/releases/download/2.2.1/pandoc-2.2.1-1-amd64.deb && \
    dpkg -i pandoc.deb && \
    rm -f pandoc.deb && \
    pip3 install --no-cache-dir -U 'chaostoolkit==1.6.0' 'chaostoolkit-reporting==0.13.0' 'chaostoolkit-azure==0.8.3' && \
    apt-get remove -y curl \
    texlive-latex-extra-doc \
    texlive-latex-recommended-doc \
    texlive-latex-base-doc \
    texlive-fonts-recommended-doc \
    texlive-pstricks-doc \
    texlive-pictures-doc && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/* /tmp/library-scripts*

RUN python3 -m venv ~/.venvs/chaostk \
    && bin/bash -c "source  ~/.venvs/chaostk/bin/activate"

FROM ghcr.io/osgeo/gdal:ubuntu-small-3.8.5

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    USE_PYGEOS=0 \
    SPATIALITE_LIBRARY_PATH='mod_spatialite.so' \
    SHELL=bash \
    TINI_VERSION=v0.19.0

ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

RUN apt update \
  && apt install -y curl \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt update \
  && apt install -y --fix-missing --no-install-recommends \
    python3-full \
    python3-dev \
    python3-venv \
    python3-pip \
    # developer convenience
    file \
    fish \
    git \
    graphviz \
    htop \
    iproute2 \
    iputils-ping \
    jq \
    less \
    libtiff-tools \
    net-tools \
    openssh-client \
    postgresql \
    postgresql-client \
    rsync \
    simpleproxy \
    sudo \
    tig \
    time \
    tmux \
    unzip \
    vim \
    wget \
    xz-utils \
    zip  \
    # rgsislib dependencies
    libboost-date-time1.74.0 \
    libboost-dev \
    libboost-filesystem1.74.0 \
    libboost-system1.74.0 \
    libcgal-dev \
    libgeos-dev \
    libgsl-dev \
    libmuparser2v5 \
    libpq-dev \
    libproj-dev \
    # for cython to work need compilers
    build-essential \
    # for pyRAT install or something
    libfftw3-dev \
    liblapack-dev \
    # install libhdf5
    libhdf5-dev \
    # install ffmpeg the normal way
    ffmpeg \
    nodejs \
    # install texlive
    texlive-fonts-recommended \
    texlive-plain-generic\
    texlive-xetex \
    # Spatialite support
    libsqlite3-mod-spatialite \
  && apt clean autoclean \
  && apt autoremove \
  && rm -rf /var/lib/{apt,dpkg,cache}

# Install yq
RUN wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

# install pandoc 3.4.1
RUN wget https://github.com/jgm/pandoc/releases/download/3.4/pandoc-3.4-1-amd64.deb
RUN dpkg -i pandoc-3.4-1-amd64.deb
RUN rm pandoc-3.4-1-amd64.deb

# Set up the python virtual environment PEP 668.
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

COPY requirements.txt /conf/

RUN python -m pip install --upgrade pip pip-tools
RUN pip install --no-cache-dir --requirement /conf/requirements.txt

RUN jupyter server extension enable --py --sys-prefix jupyterlab_iframe jupyter_resource_usage

ENV JUPYTERLAB_DIR=$VIRTUAL_ENV/share/jupyter/lab
COPY assets/overrides.json $JUPYTERLAB_DIR/settings/
COPY assets/jupyter_lab_config.py /etc/jupyter/

WORKDIR /notebooks

ENTRYPOINT ["/tini", "--"]
CMD ["jupyter",  "lab", "--allow-root",  "--ip=0.0.0.0", "--no-browser",  "--port=8888"]


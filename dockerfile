# Use the official Jupyter base notebook image with Python 3.11
FROM quay.io/jupyter/scipy-notebook:python-3.11

LABEL maintainer="Hu Chuan-Peng <hcp4715@hotmail.com>"

# Build-time argument (Docker sets TARGETARCH automatically: amd64 / arm64)
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH}

# Set environment variables to minimize Docker image size
ENV CONDA_AUTO_UPDATE_CONDA=false \
    PATH="/opt/conda/bin:$PATH"

USER root
RUN apt-get update && apt-get install -y --no-install-recommends graphviz
# Create a new conda environment and install packages
RUN conda install -y \
    graphviz \
    bambi=0.13.0 \
    pymc=5.16.2 \
    PreliZ=0.9.0 \
    ipympl=0.9.4 \
    pingouin=0.5.4 && \
    conda clean --all --yes

# Remove cache and unused packages to reduce image size
RUN rm -rf /home/jovyan/.cache && \
    conda clean --all --yes && \
    fix-permissions /home/jovyan

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# R pre-requisites
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    fonts-dejavu \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc \
    gfortran \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    
# R packages including IRKernel which gets installed globally.
RUN mamba install --yes \
    'r-base' \
    'r-car' \
    'r-caret' \
    'r-crayon' \
    'r-devtools' \
    'r-e1071' \
    'r-forecast' \
    'r-ggpubr' \
    'r-gridExtra' \
    'r-hexbin' \
    'r-htmltools' \
    'r-htmlwidgets' \
    'r-irkernel' \
    'r-nycflights13' \
    'r-randomforest' \
    'r-rcurl' \
    'r-rmarkdown' \
    'r-rodbc' \
    'r-rsqlite' \
    'r-shiny' \
    'r-tidymodels' \
    'r-tidyverse' \
    'r-brms' \
    'r-rstan' \
    'r-cmdstanr' \
    'r-BayesFactor' \
    'r-bayestestR' \
    'r-easystats' \
    'r-tidybayes' \
    'r-bayesplot' \
    'r-TOSTER' \
    'r-BH' \
    'r-pacman' \
    'r-patchwork' \
    'r-papaja' && \
    mamba clean --all -f -y 

# Install specified R packages that were not installed from conda-forge
# from different mirrors using R command, e.g.,repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/'
RUN R -e "install.packages(c('bruceR'), \
    dependencies = TRUE, repos = 'http://cran.rstudio.com/')" ; \
    rm -rf /tmp/downloaded_packages/ /tmp/*.rds /tmp/Rtmp* && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"
# Set the working directory
USER $NB_UID
WORKDIR $HOME

# Expose the default Jupyter notebook port
EXPOSE 8888

# Command to start Jupyter Notebook
CMD ["start-notebook.sh"]
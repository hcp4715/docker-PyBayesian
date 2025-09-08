# Use the official Jupyter base notebook image with Python 3.12
FROM quay.io/jupyter/scipy-notebook:python-3.12

LABEL maintainer="Hu Chuan-Peng <hcp4715@hotmail.com>"

# Set environment variables to minimize Docker image size
ENV CONDA_AUTO_UPDATE_CONDA=false \
    PATH="/opt/conda/bin:$PATH"

USER root
RUN apt-get update && apt-get install -y graphviz
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

USER root

# R pre-requisites
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
    fonts-dejavu \
    unixodbc \
    unixodbc-dev \
    r-cran-rodbc \
    gfortran \
    gcc && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
    
# R packages including IRKernel which gets installed globally.
# r-e1071: dependency of the caret R package
RUN mamba install --yes \
    'r-base' \
    'r-caret' \
    'r-crayon' \
    'r-devtools' \
    'r-e1071' \
    'r-forecast' \
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
    'r-ggplot2' \
    'r-dplyr' \
    'r-bayestestR' \
    'r-easystats' \
    'r-tidybayes' \
    'r-bayesplot' \
    'r-car' \
    'r-ggpubr' \
    'r-TOSTER' \
    'r-BH' \
    'r-pacman' \
    'unixodbc' && \
    mamba clean --all -f -y 

# Install specified R packages from Tsinghua CRAN mirror using R command
RUN R -e "install.packages(c('gridExtra', 'bruceR', 'BayesFactor', 'papaja'), \
    dependencies = TRUE, \
    repos = 'https://mirrors.tuna.tsinghua.edu.cn/CRAN/')" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"


# Set the working directory
USER $NB_UID
WORKDIR $HOME

# Expose the default Jupyter notebook port
EXPOSE 8888

# Command to start Jupyter Notebook
CMD ["start-notebook.sh"]
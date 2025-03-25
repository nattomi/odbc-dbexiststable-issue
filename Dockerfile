FROM rocker/tidyverse:4.4.3

ARG ODBC_VERSION=1.5.0
ARG CRAN=https://cloud.r-project.org

# Set environment to avoid prompts during installation
ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/opt/db2/clidriver/bin:$PATH \
    LD_LIBRARY_PATH=/opt/db2/clidriver/lib

# Install system dependencies required by devtools and its dependencies
RUN apt-get update && apt-get install --no-install-recommends -y \
    unixodbc-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy clidriver to /opt/db2
COPY clidriver /opt/db2/clidriver
COPY db2cli.ini /opt/db2/clidriver/cfg

# Copy odbc ini files
COPY odbc.ini /etc/
COPY odbcinst.ini /etc/

RUN Rscript -e "devtools::install_version('odbc', \
                                          version = '${ODBC_VERSION}', \
                                          repos = '${CRAN}')"

# Ensure the /data directory exists
RUN mkdir -p /data

# Set the default command
CMD ["/bin/bash"]

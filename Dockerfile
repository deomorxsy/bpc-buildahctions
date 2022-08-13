FROM gcr.io/datamechanics/spark:3.2.1-hadoop-3.3.1-java-8-scala-2.12-python-3.8-dm17

ARG R_VERSION="4.0.4"
ARG LIBARROW_BINARY="true"
ARG RSPM_CHECKPOINT=2696074
ARG CRAN="https://packagemanager.rstudio.com/all/__linux__/focal/${RSPM_CHECKPOINT}"

USER root

RUN echo "deb http://cloud.r-project.org/bin/linux/debian buster-cran40/" >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7'
RUN apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install software-properties-common -yq \
    && apt-get update -yqq \
    && apt-add-repository universe -y \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
	&& apt-get install -y --no-install-recommends \
        git \
        jq \
        libicu63 \
        libreadline7 \
        libcurl4-openssl-dev \
        libgit2-dev \
        libmagick++-dev \
        libpq-dev \
        libsecret-1-dev \
        libsodium-dev \
        libssl-dev \
        libxml2-dev \
        ssh \
        wget \
        cmake \
    && apt-get install -y --no-install-recommends -t \
        buster-cran40 r-base \
        r-base-dev \
        r-recommended

RUN Rscript -e "install.packages(c('littler', 'docopt'), repo = 'https://cloud.r-project.org/')"

RUN ln -fs /usr/local/lib/R/site-library/littler/bin/r /usr/bin/r \
    && ln -fs /usr/local/lib/R/site-library/littler/examples/install2.r /usr/bin/install2.r \
    && ln -fs /usr/local/lib/R/site-library/littler/examples/installGithub.r /usr/bin/installGithub.r \
    && echo "R_LIBS_USER=${R_LIBS_USER-'/usr/local/lib/R/site-library/'}"  >> /usr/lib/R/etc/Renviron

RUN Rscript -e "install.packages(c('sparklyr', 'tidyverse'), dependencies=TRUE)"

RUN mkdir -p /opt/spark/work-dir/R/ /opt/spark/logs/ /mnt/spark/data/ /mnt/spark/work/
COPY *.R /opt/spark/work-dir/R/


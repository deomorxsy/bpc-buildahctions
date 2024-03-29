FROM gcr.io/datamechanics/spark:3.2.1-hadoop-3.3.1-java-8-scala-2.12-python-3.8-dm17

ARG R_VERSION="4.0.4"
ARG LIBARROW_BINARY="true"
ARG RSPM_CHECKPOINT=2696074
ARG CRAN="https://packagemanager.rstudio.com/all/__linux__/focal/${RSPM_CHECKPOINT}"
ARG DISTRO_VERSION="$(lsb_release -sc)"

USER root

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-key '40976EAF437D05B5' \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-key '3B4FE6ACC0B21F32' \
    && echo "deb http://cloud.r-project.org/bin/linux/debian buster-cran40/" >> /etc/apt/sources.list \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-key '95C0FAF38DB3CCAD0C080A7BDC78B2DDEABC47B7' \
    && echo "deb http://archive.ubuntu.com/ubuntu xenial main restricted universe multiverse" >> /etc/apt/sources.list \
	&& echo "deb-src http://archive.ubuntu.com/ubuntu xenial main  restricted universe multiverse" >> /etc/apt/sources.list \
	&& echo "deb http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse/" >> /etc/apt/sources.list \
	&& echo "deb-src http://archive.ubuntu.com/ubuntu xenial-updates main restricted universe multiverse" >> /etc/apt/sources.list \
	&& echo "deb http://archive.ubuntu.com/ubuntu xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list \
	&& echo "deb-src http://archive.ubuntu.com/ubuntu xenial-backports main restricted universe multiverse" >> /etc/apt/sources.list \
	&& echo "deb http://archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
	&& echo "deb-src http://archive.ubuntu.com/ubuntu xenial-security main restricted universe multiverse" >> /etc/apt/sources.list \
	&& echo "#deb http://archive.ubuntu.com/ubuntu xenial-proposed restricted main universe multiverse" >> /etc/apt/sources.list \
	&& echo "#deb-src http://archive.ubuntu.com/ubuntu xenial-proposed restricted main universe multiverse" >> /etc/apt/sources.list \
	&& echo "deb http://archive.canonical.com/ubuntu xenial partner" >> /etc/apt/sources.list \
	&& echo "deb-src http://archive.canonical.com/ubuntu xenial partner" >> /etc/apt/sources.list

RUN apt clean \
    && apt update \
    && apt dist-upgrade \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install software-properties-common -yqq \
    && apt-get update -yqq \
    && apt-add-repository "deb http://archive.ubuntu.com/ubuntu ${DISTRO_VERSION} universe -y"

RUN apt-get update -yqq \
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


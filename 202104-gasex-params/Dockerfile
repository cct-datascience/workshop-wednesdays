FROM rocker/binder:3.6.3

# Copy repo into ${HOME}, make user own $HOME, install JAGS
USER root
COPY . ${HOME}
RUN chown -R ${NB_USER} ${HOME}
RUN apt-get update && . /etc/environment \
  && wget sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Source/JAGS-4.3.0.tar.gz  -O jags.tar.gz \
  && tar -xf jags.tar.gz \
  && cd JAGS* && ./configure && make -j4 && make install
USER ${NB_USER}

## run any install.R scripts we find
RUN if [ -f install.R ]; then R --quiet -f install.R; fi

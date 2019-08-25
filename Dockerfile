# Need to be ARG for the FROM command
ARG CRYSTAL_VERSION
ARG CRYSTAL_VERSION=0.30.1

FROM crystallang/crystal:${CRYSTAL_VERSION}

# Need to be env for the RUN command
ENV LUCKY_VERSION v0.17.0
ENV OVERMIND_VERSION v2.0.0


# Getting Depedencies
RUN apt-get update \
        && apt-get install -y git libc6-dev libevent-dev libpcre2-dev libpng-dev libssl-dev libyaml-dev zlib1g-dev curl wget

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list \
      && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
      && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 58118E89F3A912897C070ADBF76221572C52609D 514A2AD631A57A16DD0047EC749D6EEC0353B12C

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN echo 'export PATH="/usr/local/bin:/root/.yarn/bin:/root/.config/yarn/global/node_modules/.bin:$PATH"' >> /root/.bashrc
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

RUN apt-get update && apt-get install -y yarn tmux postgresql-9.6

RUN set -ex \
        && wget -q https://github.com/DarthSim/overmind/releases/download/$OVERMIND_VERSION/overmind-$OVERMIND_VERSION-linux-amd64.gz \
        && gunzip overmind-$OVERMIND_VERSION-linux-amd64.gz \
        && chmod +x overmind-$OVERMIND_VERSION-linux-amd64 \
        && mv overmind-$OVERMIND_VERSION-linux-amd64 /usr/local/bin/overmind

# Cloning the Lucky repo and building Lucky
RUN set -ex \
        && git clone https://github.com/luckyframework/lucky_cli \
        && cd lucky_cli \
        && git checkout $LUCKY_VERSION \
        && shards install \
        && crystal build src/lucky.cr --release --no-debug \
        && mv lucky /usr/local/bin/lucky \
        && cd .. \
        && rm -r lucky_cli





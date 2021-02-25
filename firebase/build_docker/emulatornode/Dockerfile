ARG GCLOUD_SDK_VERSION=latest

FROM google/cloud-sdk
MAINTAINER pinkfishfog

FROM google/cloud-sdk

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y  \
        nodejs \
        yarn \
        wget \
    && apt-get -qyy autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -qyy clean \
    && npm install -g firebase-tools \
    && firebase setup:emulators:database

CMD [ "/bin/bash" ]

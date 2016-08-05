
FROM ubuntu:16.04
MAINTAINER Aleksandr Zykov <tiger@mano.email>

ENV DEBIAN_FRONTEND noninteractive

RUN ( \
        apt-get update -q &&\
        apt-get upgrade -qy --no-install-recommends \
    ) && \
    apt-get clean -qy

RUN ( \
        apt-get install -qy --no-install-recommends \
            coreutils \
            dnsutils \
            iputils-ping \
            ca-certificates \
            wget \
            curl \
            net-tools \
            iptables \
            figlet \
    ) && \
    apt-get clean -qy
    
RUN figlet 'node.js'

RUN ( \
        apt-get install -qy --no-install-recommends \
            xz-utils \
    ) && \
    apt-get clean -qy

    
# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NPM_CONFIG_LOGLEVEL warn
ENV NODE_VERSION 4.4.7

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
  && curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
  && rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt

RUN figlet 'Dependencies'

RUN ( \
        apt-get install -qy --no-install-recommends \
            git \
            build-essential \
    ) && \
    apt-get clean -qy
    
RUN ( \
        npm install --no-optional -g \
            babel-cli \
            sequelize-cli \
            node-gyp \
    )
    
ENV NODE_ENV development

ENV STEEMIT_REPO https://github.com/steemit/steemit.com
ENV STEEMIT_COMMIT e5f8b881fedb870245222d2acf6c9bd3c0a5d792
    
RUN figlet 'steemit.com '

RUN ( \
        cd /root; \
        git clone $STEEMIT_REPO steemit \
    )

RUN ( \
        cd /root/steemit; \
        ( \
            /usr/bin/test -n "$STEEMIT_COMMIT" && \
              git checkout $STEEMIT_COMMIT || \
              /bin/true \
        ) \
    )

ADD package.json.diff /root/steemit/

RUN  cd /root/steemit/; \
    ( \
        cat package.json.diff && \
        patch <package.json.diff \
    )
    
ADD babelrc.diff /root/steemit/babelrc.diff

RUN cd /root/steemit/ ; \
    ( \
        cat babelrc.diff && \
        patch <babelrc.diff \
    )
    
RUN cd /root/steemit/; \
    ( \
        NODE_ENV=development npm install --no-optional --no-shrinkwrap \
    )

# RUN cd /root/steemit; \
#     ( \
#         npm run build \
#     )

RUN mkdir -p /root/steemit/data/

ADD db-config.json /root/steemit/db/config/config.json

RUN cd /root/steemit/db; \
    cat config/config.json &&\
    ( \
        sequelize db:migrate \
    )

ADD config.json /root/steemit/config.json.sample

ENV PORT 3000

ADD run-steemit.sh /root/steemit/ 

RUN ls -l /root/steemit

EXPOSE 3000 3001

VOLUME ["/root/steemit/data"]

CMD ["/root/steemit/run-steemit.sh"]

RUN figlet 'Happy Steeming!'


FROM teego/steemit-bundle-software:latest
MAINTAINER Aleksandr Zykov <tiger@mano.email>

RUN figlet 'Building'

RUN ( \
        apt-get install -qy --no-install-recommends \
            socat \
    ) && \
    apt-get clean -qy

ADD babelrc.diff /root/steemit/babelrc.diff

RUN cd /root/steemit/; \
    ( \
        cat babelrc.diff && \
        patch <babelrc.diff \
    )
    
RUN mkdir -p /root/steemit/data/

ADD db-config.json /root/steemit/db/config/config.json

RUN cd /root/steemit/db; \
    cat config/config.json &&\
    ( \
        sequelize db:migrate \
    )

ADD config.json /root/steemit/config.json.sample

ADD run-steemit.sh /root/steemit/ 

ADD server.diff /root/steemit/server/server.js.diff

RUN cd /root/steemit/; \
    ( \
        cat server/server.js.diff && \
        patch <server/server.js.diff \
    )
    
RUN ls -l /root/steemit

EXPOSE 80

VOLUME ["/root/steemit/data"]

CMD ["/root/steemit/run-steemit.sh"]

RUN figlet 'Happy Steeming'

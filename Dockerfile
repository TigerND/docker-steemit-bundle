
FROM teego/steemit-bundle-software:latest
MAINTAINER Aleksandr Zykov <tiger@mano.email>

RUN figlet 'Building'

ADD babelrc.diff /root/steemit/babelrc.diff

RUN cd /root/steemit/ ; \
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

ENV PORT 3000

ADD run-steemit.sh /root/steemit/ 

RUN ls -l /root/steemit

EXPOSE 3000 3001

VOLUME ["/root/steemit/data"]

CMD ["/root/steemit/run-steemit.sh"]

RUN figlet 'Happy Steeming'

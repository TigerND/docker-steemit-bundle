#!/bin/bash

figlet 'Steemit'

if [[ ! -f /root/steemit/data/config.json ]]; then
    cp /root/steemit/config.json.sample /root/steemit/data/config.json
fi
ln -sf /root/steemit/data/config.json /root/steemit/config/steem.json
ln -sf /root/steemit/data/config.json /root/steemit/config/steem-dev.json

if [[ ! -f /root/steemit/data/steemit.sqlite ]]; then
    cp /root/steemit/steemit.sqlite.empty /root/steemit/data/steemit.sqlite
fi

socat TCP-LISTEN:80,reuseaddr,fork TCP:127.0.0.1:3000 &

export PORT=3000

cd /root/steemit
npm run prod $*
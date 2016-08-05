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

cd /root/steemit

npm start $*
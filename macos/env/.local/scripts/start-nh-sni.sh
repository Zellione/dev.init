#!/bin/zsh

tmux new-window -dn charybdis 'npm run start:charybdis'
tmux new-window -dn config-server 'npm run start:config-server'
tmux new-window -dn deichshaper 'npm run start:deichshaper'
tmux new-window -dn storefront-sni 'npm run start:storefront-sni'

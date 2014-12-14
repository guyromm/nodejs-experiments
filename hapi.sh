#!/bin/bash
node_modules/coffee-script/bin/coffee -cw hapi.coffee & node_modules/nodemon/bin/nodemon.js hapi.js

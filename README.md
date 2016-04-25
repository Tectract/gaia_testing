# gaia_testing

Testing endpoint API for Gaia video lookup

setup:
(install npm on your system)
npm install pm2 -g
npm i

run with:
pm2 start server.js
pm2 restart server.js

test via:

curl http://localhost:4000/v1/api/term/26681/longest-preview-media-url

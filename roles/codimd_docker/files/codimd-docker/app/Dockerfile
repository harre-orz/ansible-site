FROM node:10.15

COPY codimd /codimd
WORKDIR /codimd

COPY sequelizerc /codimd/.sequelizerc
RUN npm install \
 && npm run build \
 && npm prune --production

COPY config.json /codimd/config.json

EXPOSE 3000
CMD [ "node", "app.json" ]

FROM node:8-alpine as build
RUN mkdir -p /usr/src/app/sass
RUN mkdir -p /usr/src/app/css
WORKDIR /usr/src/app
COPY package*.json ./
COPY ./scss/site.scss ./sass/site.scss
RUN npm install
RUN npm start
CMD cat ./css/site.min.css

FROM nginx:alpine as cert-gen

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
RUN apk add openssl && apk add bash
SHELL ["/bin/bash", "-c"]
WORKDIR /work
RUN openssl req -x509 -out localhost.crt -keyout localhost.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=localhost' -extensions EXT -config <( \
   printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
RUN openssl dhparam -out localhost.pem 2048

FROM nginx:alpine 
RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/*
RUN mkdir -p /var/www/css
RUN mkdir -p /etc/ssl
COPY --from=cert-gen /work/localhost.key /etc/ssl/
COPY --from=cert-gen /work/localhost.crt /etc/ssl/
COPY --from=cert-gen /work/localhost.crt /usr/local/share/ca-certificates/localhost.crt
COPY --from=cert-gen /work/localhost.pem /etc/ssl/
COPY --from=build /usr/src/app/css/site.min.css /var/www/css
ADD html /var/www/html
RUN chmod -R 0755 /var/www
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
RUN update-ca-certificates

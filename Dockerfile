FROM node:8-alpine
RUN mkdir -p /usr/src/app/sass
RUN mkdir -p /usr/src/app/css
WORKDIR /usr/src/app
COPY package*.json ./
COPY site.scss ./sass/site.scss
RUN npm install
RUN npm start
CMD cat ./css/site.min.css



FROM node:0.10

RUN mkdir -p /usr/src/app
RUN git clone https://github.com/mapbox/mapbox-studio-classic.git /usr/src/app
WORKDIR /usr/src/app

RUN npm install

VOLUME /projects
ENV PORT=3000
EXPOSE 3000
CMD ["npm", "start"]

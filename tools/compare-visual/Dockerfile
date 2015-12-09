FROM node:0.10

RUN mkdir -p /usr/src/app/
WORKDIR /usr/src/app
RUN npm install http-proxy

COPY compare.js /usr/src/app/
COPY index.html /usr/src/app/

EXPOSE 3000
EXPOSE 3001
CMD ["node", "compare.js"]

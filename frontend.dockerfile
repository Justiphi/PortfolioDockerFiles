FROM node:22-alpine
WORKDIR /app

RUN apk add --no-cache git
RUN npm install -g npm@12

RUN git clone --depth 1 https://github.com/Justiphi/reactportfolio.git .

COPY frontend.env ./.env

RUN npm install

EXPOSE 3000
CMD ["npm", "start"]
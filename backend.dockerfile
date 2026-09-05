FROM node:22-alpine
WORKDIR /app

RUN apk add --no-cache git
RUN npm install -g npm@12

RUN git clone --depth 1 https://github.com/Justiphi/reactportfolio.git /tmp/repo
RUN cp -r /tmp/repo/backend/. . && rm -rf /tmp/repo

COPY backend.env ./.env

RUN npm ci --omit=dev

# Adjust this port to whatever the backend actually listens on
EXPOSE 8000

CMD ["node", "server.js"]
FROM node:8.11-alpine

WORKDIR /app

COPY src/package.json src/package-lock.json ./
RUN npm i

COPY src .
COPY cowsay-entrypoint.sh v.txt /
RUN chmod +x /cowsay-entrypoint.sh

ENTRYPOINT ["/cowsay-entrypoint.sh"]

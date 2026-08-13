# Stage 1: Builder - instala dependências
FROM node:18-alpine AS builder

WORKDIR /app

COPY package.json ./

RUN npm install --production

# Stage 2: Production - copia artefatos e roda a aplicação
FROM node:18-alpine

WORKDIR /app

COPY --from=builder /app/node_modules ./node_modules

COPY . .

EXPOSE 3000

CMD ["node", "server.js"]

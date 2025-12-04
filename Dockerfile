# Estágio "base"
FROM node:22-alpine AS base
WORKDIR /app
RUN corepack enable
RUN addgroup -S appgroup && adduser -D -s /bin/sh -G appgroup appuser

# Alvo "prod" - Imagem Final para Produção
FROM base AS prod
WORKDIR /app
COPY --from=builder /app/package.json /app/pnpm-lock.yaml ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/static ./.next/static
USER appuser
EXPOSE 3000
ENV PORT 3000
ENV NODE_ENV production
CMD ["node", "server.js"]

# Estágio "builder" - Usado APENAS durante o build da imagem de produção
FROM base AS builder
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm run build
RUN pnpm prune --prod

# Alvo "dev" - Para Desenvolvimento com Devcontainer
FROM base AS dev
WORKDIR /app
RUN apk add --no-cache git openssh-client
RUN chown -R appuser:appgroup /app
USER appuser
EXPOSE 3000
CMD ["sleep", "infinity"]
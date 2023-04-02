FROM node:19-alpine AS base
ARG HOME
ENV HOME=/app

# Dependency installation
FROM base AS dep
WORKDIR $HOME
RUN apk add --no-cache g++ python3 make		# Docker wont build on my mac without this :(
COPY package.json .
COPY package-lock.json .
RUN npm install 

# Build stage
FROM dep AS builder
WORKDIR $HOME
COPY . .
RUN npm run build 

# Execution stage
FROM base AS runner
WORKDIR $HOME
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
COPY --from=builder $HOME/public .
COPY --from=builder --chown=nextjs:nodejs $HOME/.next/standalone .
COPY --from=builder --chown=nextjs:nodejs $HOME/.next/static ./.next/static
USER nextjs
CMD [ "node", "server.js" ]

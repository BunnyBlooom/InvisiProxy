FROM node:20-bookworm-slim
WORKDIR /app
LABEL org.opencontainers.image.title="InvisiProxy LTS" \
      org.opencontainers.image.description="An effective, privacy-focused web proxy service" \
      org.opencontainers.image.version="7.0.1" \
      org.opencontainers.image.authors="InvisiProxy Team" \
      org.opencontainers.image.source="https://github.com/QuiteAFancyEmerald/InvisiProxy/"
RUN apt-get update \
      && apt-get install -y --no-install-recommends tor bash python3 python3-pip make g++ gcc libc6-dev \
      && rm -rf /var/lib/apt/lists/*
RUN npm install -g corepack
RUN corepack enable && corepack prepare pnpm@10.12.4 --activate

COPY . .
RUN pnpm run fresh-install
RUN pnpm exec playwright install --with-deps chromium
RUN pnpm run build
EXPOSE 8080 9050 9051
HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
      CMD node -e "fetch('http://127.0.0.1:8080/login').then((response) => { if (!response.ok) process.exit(1); }).catch(() => process.exit(1))"
COPY serve.sh /serve.sh
RUN chmod +x /serve.sh
CMD ["/serve.sh"]
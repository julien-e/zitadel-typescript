#  Copier les fichiers de dépendances
COPY package*.json ./
COPY yarn.lock* ./
COPY pnpm-lock.yaml* ./

# Installer les dépendances
RUN if [ -f yarn.lock ]; then yarn install --frozen-lockfile; \
    elif [ -f pnpm-lock.yaml ]; then npm install -g pnpm && pnpm install --frozen-lockfile; \
    else npm ci; fi

# Copier le code source
COPY . .

# Build de l'application
RUN if [ -f yarn.lock ]; then yarn build; \
    elif [ -f pnpm-lock.yaml ]; then pnpm build; \
    else npm run build; fi

# Stage 2: Production
FROM node:18-alpine

WORKDIR /app

# Copier les fichiers nécessaires depuis le builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV LANGUAGE=fr
ENV LOCALE=fr-FR

# Exposer le port
EXPOSE 3000

# Démarrer l'application
CMD ["node", "dist/index.js"]

FROM node:20-slim

# Install PostgreSQL 17 client
RUN apt-get update && apt-get install -y curl gnupg2 lsb-release \
    && echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update && apt-get install -y postgresql-client-17 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy application source
COPY . .

# Increase Node.js heap size to 1536MB to prevent OOM during Vite build
ENV NODE_OPTIONS="--max-old-space-size=1536"

# Build the frontend and backend
RUN npm run build

# Reset NODE_OPTIONS for runtime (not needed at runtime)
ENV NODE_OPTIONS=""

# Expose the API port
EXPOSE 5000

# Start the application
CMD ["npm", "run", "start"]


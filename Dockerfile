# Use an official lightweight Node image
FROM node:24.14.1-slim

# Install system dependencies including Git, JQ, and Nginx
RUN apt-get update && apt-get install -y git jq nginx && rm -rf /var/lib/apt/lists/*

# Set working directory inside the container
WORKDIR /app

# Copy all codebase files into the container
COPY . .

# Force fix the absolute path crash by creating a system symbolic link
RUN ln -s /app/packages /packages

# Initialize a dummy git repository inside Render to trick the wrangler config tool
RUN git config --global user.email "server@rec.room" && \
    git config --global user.name "RecServer" && \
    git init && \
    git add . && \
    git commit -m "Render execution init"

# Enable corepack, fetch pnpm, and install project dependencies internally
RUN corepack enable && corepack prepare pnpm@latest --activate && pnpm install --frozen-lockfile

# Configure a background proxy routing layer to expose the master API gateway (Wrangler defaults to 8787)
RUN echo 'server { \
    listen 8080; \
    location / { \
        proxy_pass http://127.0.0.1:8787; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
}' > /etc/nginx/sites-available/default

# Expose the internal communications port 
EXPOSE 8080
#Made by Arnie on the 3/09/26

# Start Nginx in the background and execute the workspace microservice apps sequentially
CMD service nginx start && pnpm --filter "*" run dev

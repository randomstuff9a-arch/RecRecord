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

# Configure Nginx to bridge external port 8080 to our open worker instance on port 8787
RUN echo 'server { \
    listen 8080; \
    location / { \
        proxy_pass http://0.0.0; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
        proxy_set_header X-Forwarded-Proto $scheme; \
    } \
}' > /etc/nginx/sites-available/default

# Expose the internal communications port 
EXPOSE 8080

# Start Nginx and launch the core workspace app with a remote-public binding layout
CMD service nginx start && pnpm --filter "www" run dev --ip 0.0.0.0 --port 8787 --remote

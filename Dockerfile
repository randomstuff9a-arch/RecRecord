# Use an official lightweight Node image
FROM node:24.14.1-slim

# Install core system tools (Git and JQ)
RUN apt-get update && apt-get install -y git jq && rm -rf /var/lib/apt/lists/*

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

# Force wrangler dev to listen globally on port 8080 right from the source execution line
ENV WRANGLER_PORT=8080
ENV WRANGLER_IP=0.0.0.0

# Expose the internal communications port 
EXPOSE 8080

# Launch the workspace modules with global environment network attachments
CMD pnpm --filter "*" run dev --ip 0.0.0.0 --port 8080

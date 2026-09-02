# Use an official lightweight Node image
FROM node:24.14.1-slim

# Install system dependencies including Git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

# Set working directory inside the container
WORKDIR /app

# Copy all codebase files into the container
COPY . .

# Enable corepack, fetch the correct pnpm version, and run the install command
RUN corepack enable && corepack prepare pnpm@latest --activate && pnpm install --frozen-lockfile

# Expose the internal communications port 
EXPOSE 8080

# Run the project using its workspace-specific execution filter
CMD ["pnpm", "--filter", "*", "run", "dev"]

# Use an official lightweight Node image
FROM node:24.14.1-slim

# Set working directory inside the container
WORKDIR /app

# Copy all codebase files into the container
COPY . .

# Enable corepack and install project dependencies internally
RUN corepack enable && yarn install

# Expose the internal communications port 
EXPOSE 8080

# Execute the start script defined in package.json
CMD ["yarn", "start"]

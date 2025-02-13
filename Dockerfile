# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json (if exists)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files
COPY . .

# Expose the port (for local convenience)
EXPOSE 3000

# Start the application
CMD [ "node", "app.js" ]
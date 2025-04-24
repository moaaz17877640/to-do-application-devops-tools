# Use a Node.js base image
FROM node:alpine

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the application source code
COPY ./src ./src

# Expose port 3000
EXPOSE 3000

# Start the Node.js app
CMD ["npm", "run", "dev"]
# Use Node 16 LTS
FROM node:16

# Create app directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --only=production

# Copy app source
COPY . .

# Expose port 
EXPOSE 8080

# Start the app
CMD ["node", "app.js"]

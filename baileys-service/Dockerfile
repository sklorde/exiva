FROM node:20-slim

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production --loglevel=error

# Copy application code
COPY . .

# Create directory for auth data and logs
RUN mkdir -p /app/auth_info /app/logs && chmod 777 /app/auth_info /app/logs

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {if(r.statusCode !== 200) throw new Error('unhealthy')})"

# Start the application
CMD ["npm", "start"]

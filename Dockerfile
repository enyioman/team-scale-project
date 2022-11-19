FROM node:16-alpine AS builder

ENV NODE_ENV production
# Add a work directory
WORKDIR /app

# Copy app files
COPY . /app/

# Cache and Install dependencies
COPY package.json .
COPY package-lock.json .

RUN apt-get update \
    && apt-get upgrade -y \
    && curl -sL https://deb.nodesource.com/setup_8.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g react-tools

# Build the app
RUN npm run build

# Bundle static assets with nginx
FROM nginx:1.21.0-alpine as production
ENV NODE_ENV production

# Copy built assets from builder
COPY --from=builder /app/build /usr/share/nginx/html

# Remove default conf
RUN mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/confbackup.conf

# Add your nginx.conf
COPY nginx/nginx.conf /etc/nginx/conf.d

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 



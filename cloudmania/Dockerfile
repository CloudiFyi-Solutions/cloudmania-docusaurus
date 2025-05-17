# Use Node.js image to build the static site
FROM node:20 AS builder

WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# Use Nginx to serve the static site
FROM nginx:alpine

# Remove default Nginx site config
RUN rm -rf /usr/share/nginx/html/*

# Copy built static site to Nginx's web root
COPY --from=builder /app/build /usr/share/nginx/html

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

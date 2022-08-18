# 1. base image
FROM nginx:alpine

# 2. copy Build for production
COPY build/ /usr/share/nginx/html/

# 3. expose port
EXPOSE 80

# 4. Command to run after boot
CMD ["nginx", "-g", "daemon off;"]
FROM nginx:alpine
# Copy our custom WebRTC interface into the standard Nginx static HTML folder
COPY index.html /usr/share/nginx/html/index.html
# Expose port 80 inside the container
EXPOSE 80

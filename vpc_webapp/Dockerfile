# Use a base image
FROM nginx:alpine

# Copy your HTML file to the appropriate location
COPY index.html /usr/share/nginx/html

# Expose the default HTTP port
EXPOSE 80

# Start the nginx server
CMD ["nginx", "-g", "daemon off;"]

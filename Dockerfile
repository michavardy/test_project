##---STAGE 1---##
FROM node:14 as frontend-build
RUN mkdir app
WORKDIR /app/frontend
COPY app/package*.json ./
RUN npm install
COPY app/src/ ./src
COPY app/public/ ./public
RUN npm run build


##---STAGE 2---##
FROM nginx:alpine

# Remove the default Nginx configuration
RUN rm -rf /usr/share/nginx/html/*

# Copy the build output from the previous stage into the Nginx directory
COPY --from=frontend-build /app/frontend/build /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx when the container starts
CMD ["nginx", "-g", "daemon off;"]



#Use lightweight Node.js image as the build environment
FROM node:20-alpine AS build
#Setup working dir inside the container
WORKDIR /app
#Copy Dependency
COPY package*.json ./
#Install Dependencies
RUN npm ci --legacy-peer-deps

#Copy entire source code into the container
COPY . .

#Run optional build step
RUN npm run build || echo "no build step"

#use lightweight image for runtime env
FROM node:20-alpine AS runtime

#Set working directory
WORKDIR /app

#set environment to production
ENV NODE_ENV=production
#Copy node modules & source code from build stage
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app ./

#Expose application port
EXPOSE 3000
#Create non root user and group
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
#Set user as default
USER appuser
CMD ["node", "app.js"]


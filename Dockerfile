##---STAGE 1---##
FROM node:14 as frontend-build
RUN mkdir app
WORKDIR /app/frontend
COPY app/package*.json ./
RUN npm install
COPY app/src/ ./src
COPY app/public/ ./public
COPY .env ./
RUN npm run build

##---STAGE 2---##

# Install and build Python dependencies
FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9 as backend-build
COPY .env ./
COPY --from=frontend-build /app/frontend/build /app/frontend/build
WORKDIR /app/backend
COPY api/requirements.txt ./
RUN pip install -r requirements.txt
COPY api/ ./

EXPOSE 80
#CMD ["bin", "bash"]
CMD ["uvicorn", "--host", "0.0.0.0", "--port", "80", "--workers", "4", "backend.main:start"]


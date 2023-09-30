from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware  # Import the CORSMiddleware
from fastapi.staticfiles import StaticFiles  # Import StaticFiles

import uvicorn

app = FastAPI(openapi_prefix="/test")


# Configure CORS settings
origins = [
    "http://localhost",
    "http://localhost:80",
    "http://localhost:3000",
    "http://localhost:8000",
    "http://127.0.0.1:8000",
    "*"
]

# Add the CORSMiddleware to your app with the configured origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/hello_world")
def read_root():
    return {"Hello": "World"}

class SPAStaticFiles(StaticFiles):
    async def get_response(self, path: str, scope):
        response = await super().get_response(path, scope)
        if response.status_code == 404:
            response = await super().get_response('.', scope)
        return response

# Mount the static files directory (built React files) to the URL path "/"
app.mount("/", SPAStaticFiles(directory="/app/frontend/build", html=True), name="static")


def start():
    """Launched with `poetry run start` at root level"""
    uvicorn.run("backend.main:app", host="0.0.0.0", port=80, reload=True)
import uvicorn
from fastapi import FastAPI

app = FastAPI()


@app.get("/health")
def health() -> dict[str, str]:
    return {"status": "ok"}


def run() -> None:
    uvicorn.run("app.main:app", host="0.0.0.0", port=8000, reload=True)

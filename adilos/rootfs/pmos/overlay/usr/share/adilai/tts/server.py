#!/usr/bin/env python3
"""Minimal piper wrapper stub."""
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import base64
import uvicorn

app = FastAPI(title="AdilAI TTS", docs_url=None, redoc_url=None)


class TTSRequest(BaseModel):
    text: str


@app.post("/speak")
def speak(req: TTSRequest):
    if not req.text:
        raise HTTPException(status_code=400, detail="text required")
    fake_audio = base64.b64encode(req.text.encode("utf-8")).decode("ascii")
    return {"audio": fake_audio, "encoding": "base64"}


def main():
    uvicorn.run(app, host="127.0.0.1", port=13102)


if __name__ == "__main__":
    main()

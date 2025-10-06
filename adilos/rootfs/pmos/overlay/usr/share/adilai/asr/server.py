#!/usr/bin/env python3
"""Minimal whisper.cpp wrapper stub."""
from fastapi import FastAPI, File, UploadFile, HTTPException
import uvicorn

app = FastAPI(title="AdilAI ASR", docs_url=None, redoc_url=None)


@app.post("/transcribe")
async def transcribe(audio: UploadFile = File(...)):
    if audio.content_type not in ("audio/wav", "audio/mpeg", "audio/x-wav"):
        raise HTTPException(status_code=400, detail="unsupported audio type")
    content = await audio.read()
    # Integrate whisper.cpp inference here
    text = "[stub transcript]"
    return {"text": text, "bytes": len(content)}


def main():
    uvicorn.run(app, host="127.0.0.1", port=13101)


if __name__ == "__main__":
    main()

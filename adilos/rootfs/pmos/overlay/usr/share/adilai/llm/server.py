#!/usr/bin/env python3
"""Minimal llama.cpp wrapper stub."""
import json
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import uvicorn

app = FastAPI(title="AdilAI LLM", docs_url=None, redoc_url=None)


class GenerateRequest(BaseModel):
    prompt: str
    max_tokens: int | None = 128


@app.post("/generate")
def generate_text(req: GenerateRequest):
    if not req.prompt:
        raise HTTPException(status_code=400, detail="prompt required")
    # Placeholder inference logic. Integrate llama.cpp via subprocess or bindings.
    response = f"Hope says: {req.prompt[:128]} ..."
    return {"response": response}


def main():
    uvicorn.run(app, host="127.0.0.1", port=13100)


if __name__ == "__main__":
    main()

from __future__ import annotations

from pydantic import BaseModel, Field


class Settings(BaseModel):
    chroma_persist_dir: str = Field(default="data/chroma")
    chroma_collection: str = Field(default="policies")

    # Local embeddings via sentence-transformers (used by HuggingFaceEmbeddings).
    # Common choices: "sentence-transformers/all-MiniLM-L6-v2" (fast, English-ish),
    # "intfloat/multilingual-e5-small" (good multilingual incl. Chinese).
    embeddings_model: str = Field(default="intfloat/multilingual-e5-small")


settings = Settings()

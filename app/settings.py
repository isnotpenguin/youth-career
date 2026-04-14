 from __future__ import annotations
 
 from pydantic import BaseModel, Field
 
 
 class Settings(BaseModel):
     chroma_persist_dir: str = Field(default="data/chroma")
     chroma_collection: str = Field(default="policies")
 
     # For Ollama embeddings, LangChain uses OLLAMA_BASE_URL if set; otherwise defaults.
     ollama_model: str = Field(default="nomic-embed-text")
 
 
 settings = Settings()

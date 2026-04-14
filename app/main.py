 from __future__ import annotations
 
 from fastapi import FastAPI
 from pydantic import BaseModel, Field
 
 from app.rag import retrieve_policy_chunks
 
 
 app = FastAPI(title="Youth Career Policy Navigator - RAG API")
 
 
 class RetrieveRequest(BaseModel):
     query: str = Field(min_length=1)
     location: str | None = None
     education_background: str | None = None
     k: int = Field(default=5, ge=1, le=20)
 
 
 class RetrievedChunkOut(BaseModel):
     content: str
     metadata: dict
     score: float | None = None
 
 
 class RetrieveResponse(BaseModel):
     chunks: list[RetrievedChunkOut]
 
 
 @app.post("/retrieve", response_model=RetrieveResponse)
 def retrieve(req: RetrieveRequest) -> RetrieveResponse:
     chunks = retrieve_policy_chunks(
         query=req.query,
         location=req.location,
         education_background=req.education_background,
         k=req.k,
     )
     return RetrieveResponse(
         chunks=[RetrievedChunkOut(content=c.content, metadata=c.metadata, score=c.score) for c in chunks]
     )

 from __future__ import annotations
 
 from dataclasses import dataclass
 from typing import Any, Optional
 
 from langchain_community.embeddings import OllamaEmbeddings
 from langchain_community.vectorstores import Chroma
 
 from app.settings import settings
 
 
 @dataclass(frozen=True)
 class RetrievedChunk:
     content: str
     metadata: dict[str, Any]
     score: Optional[float] = None
 
 
 def _build_where_filter(*, location: Optional[str], education_background: Optional[str]) -> dict[str, Any]:
     """
     Chroma's metadata filter supports simple equality (and some operators).
     We use an $and when both filters are present.
     """
     clauses: list[dict[str, Any]] = []
     if location:
         clauses.append({"location": location})
     if education_background:
         clauses.append({"education_background": education_background})
 
     if not clauses:
         return {}
     if len(clauses) == 1:
         return clauses[0]
     return {"$and": clauses}
 
 
 def get_vectorstore(persist_dir: str | None = None) -> Chroma:
     embeddings = OllamaEmbeddings(model=settings.ollama_model)
     return Chroma(
         collection_name=settings.chroma_collection,
         persist_directory=persist_dir or settings.chroma_persist_dir,
         embedding_function=embeddings,
     )
 
 
 def retrieve_policy_chunks(
     *,
     query: str,
     location: Optional[str] = None,
     education_background: Optional[str] = None,
     k: int = 5,
     persist_dir: str | None = None,
 ) -> list[RetrievedChunk]:
     """
     Retrieve chunks using Chroma similarity search with metadata filtering.
 
     Metadata schema expected on each chunk:
     - location: str (e.g., "Taipei" / "Taichung" / "National")
     - education_background: str (e.g., "HighSchool" / "Bachelor" / "Master" / "Any")
     """
     vs = get_vectorstore(persist_dir=persist_dir)
     where = _build_where_filter(location=location, education_background=education_background)
 
     # Prefer score-returning search when available.
     try:
         docs_and_scores = vs.similarity_search_with_score(query, k=k, filter=(where or None))
         return [RetrievedChunk(content=d.page_content, metadata=d.metadata, score=float(s)) for d, s in docs_and_scores]
     except Exception:
         docs = vs.similarity_search(query, k=k, filter=(where or None))
         return [RetrievedChunk(content=d.page_content, metadata=d.metadata, score=None) for d in docs]

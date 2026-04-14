 from __future__ import annotations
 
 import argparse
 import hashlib
 import os
 from pathlib import Path
 from typing import Any
 
 from langchain_community.document_loaders import PyPDFLoader
 from langchain_community.embeddings import OllamaEmbeddings
 from langchain_community.vectorstores import Chroma
 from langchain_text_splitters import RecursiveCharacterTextSplitter
 
 from app.settings import settings
 
 
 def _file_sha256(path: Path) -> str:
     h = hashlib.sha256()
     with path.open("rb") as f:
         for chunk in iter(lambda: f.read(1024 * 1024), b""):
             h.update(chunk)
     return h.hexdigest()
 
 
 def _default_metadata_for_pdf(pdf_path: Path) -> dict[str, Any]:
     """
     Minimal default metadata; you can override via CLI flags.
     """
     return {
         "source": str(pdf_path),
         "filename": pdf_path.name,
         "file_sha256": _file_sha256(pdf_path),
         "doc_type": "policy_pdf",
     }
 
 
 def ingest_policies(
     *,
     pdf_dir: str,
     persist_dir: str | None = None,
     location: str = "National",
     education_background: str = "Any",
     chunk_size: int = 1200,
     chunk_overlap: int = 200,
 ) -> int:
     pdf_root = Path(pdf_dir)
     if not pdf_root.exists():
         raise FileNotFoundError(f"pdf_dir not found: {pdf_root}")
 
     pdf_paths = sorted([p for p in pdf_root.rglob("*.pdf") if p.is_file()])
     if not pdf_paths:
         return 0
 
     splitter = RecursiveCharacterTextSplitter(
         chunk_size=chunk_size,
         chunk_overlap=chunk_overlap,
         separators=["\n\n", "\n", " ", ""],
     )
 
     embeddings = OllamaEmbeddings(model=settings.ollama_model)
     vs = Chroma(
         collection_name=settings.chroma_collection,
         persist_directory=persist_dir or settings.chroma_persist_dir,
         embedding_function=embeddings,
     )
 
     total_chunks = 0
     for pdf_path in pdf_paths:
         loader = PyPDFLoader(str(pdf_path))
         docs = loader.load()
 
         base_meta = _default_metadata_for_pdf(pdf_path)
         base_meta.update(
             {
                 "location": location,
                 "education_background": education_background,
             }
         )
 
         # Attach metadata to each page doc (then splitter carries it into chunks).
         for d in docs:
             d.metadata.update(base_meta)
 
         chunks = splitter.split_documents(docs)
 
         # Ensure stable IDs for upserts (depends on file hash + chunk index).
         ids: list[str] = []
         for i, ch in enumerate(chunks):
             ch.metadata["chunk_index"] = i
             ch.metadata["chunk_size"] = chunk_size
             ch.metadata["chunk_overlap"] = chunk_overlap
             ids.append(f'{base_meta["file_sha256"]}:{i}')
 
         vs.add_documents(chunks, ids=ids)
         total_chunks += len(chunks)
 
     # Persist for faster reloads
     vs.persist()
     return total_chunks
 
 
 def main() -> None:
     parser = argparse.ArgumentParser(description="Ingest policy PDFs into Chroma.")
     parser.add_argument("--pdf_dir", required=True, help="Directory containing PDF files (recursive).")
     parser.add_argument("--persist_dir", default=None, help="Chroma persist directory (default: data/chroma).")
     parser.add_argument("--location", default=os.environ.get("POLICY_LOCATION", "National"))
     parser.add_argument("--education_background", default=os.environ.get("POLICY_EDU", "Any"))
     parser.add_argument("--chunk_size", type=int, default=1200)
     parser.add_argument("--chunk_overlap", type=int, default=200)
     args = parser.parse_args()
 
     n = ingest_policies(
         pdf_dir=args.pdf_dir,
         persist_dir=args.persist_dir,
         location=args.location,
         education_background=args.education_background,
         chunk_size=args.chunk_size,
         chunk_overlap=args.chunk_overlap,
     )
     print(f"Ingested {n} chunks into Chroma.")
 
 
 if __name__ == "__main__":
     main()

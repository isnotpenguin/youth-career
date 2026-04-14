 ## Youth Career Policy Navigator — RAG Pipeline
 
 This project implements:
 - PDF ingestion with `RecursiveCharacterTextSplitter`
 - ChromaDB persistence with per-chunk metadata
 - Retrieval with **metadata filtering** on `location` and `education_background`
 - A small FastAPI API for querying
 
 ### Prereqs
 - Python 3.11+
 - (Recommended) Ollama installed and running (`ollama serve`)
 
 ### Setup
 
 ```bash
 python -m venv .venv
 source .venv/bin/activate
 pip install -U pip
 pip install -e .
 ```
 
 ### Add PDFs
 Put government policy PDFs under `data/policies/`.
 
 ### Ingest PDFs into Chroma
 
 ```bash
 python -m app.ingest --pdf_dir data/policies --persist_dir data/chroma
 ```
 
 ### Run the API
 
 ```bash
 uvicorn app.main:app --reload
 ```
 
 Then query:
 
 ```bash
 curl -X POST http://127.0.0.1:8000/retrieve \
   -H 'Content-Type: application/json' \
   -d '{
     "query": "What subsidies exist for youth internships?",
     "location": "Taipei",
     "education_background": "Bachelor"
   }'
 ```

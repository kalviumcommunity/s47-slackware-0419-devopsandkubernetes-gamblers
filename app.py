"""
FastAPI application for PDF text extraction.
Provides API endpoints to upload PDFs and extract text content.
"""

from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import logging
from datetime import datetime
import os
import PyPDF2
from io import BytesIO

# Create FastAPI app
app = FastAPI(
    title="PDF Text Extractor API",
    description="Extract text from PDF files using FastAPI",
    version="1.0.0"
)

# Configure CORS to allow requests from React frontend
origins = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:8000",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Application configuration from environment
APP_ENV = os.getenv('APP_ENV', 'development')
APP_VERSION = os.getenv('APP_VERSION', '1.0.0')


@app.get('/')
def home():
    """Root endpoint with basic application info."""
    logger.info("Home endpoint accessed")
    return {
        'status': 'success',
        'message': 'PDF Text Extractor API',
        'version': APP_VERSION,
        'environment': APP_ENV,
        'timestamp': datetime.utcnow().isoformat()
    }


# Global state variables for demonstrating Kubernetes Probes
APP_STATE = {
    'is_alive': True,
    'is_ready': True
}

@app.get('/liveness')
def liveness_check():
    """Liveness probe: Checks if container is alive and running. If 500, K8s RESTARTS the pod."""
    if not APP_STATE['is_alive']:
        logger.error("Liveness probe failed! App is simulated as dead.")
        raise HTTPException(status_code=500, detail="Application is dead")
    return {"status": "alive"}

@app.get('/readiness')
def readiness_check():
    """Readiness probe: Checks if app can handle traffic. If 500, K8s STOPS SENDING TRAFFIC, but no restart."""
    if not APP_STATE['is_ready']:
        logger.warning("Readiness probe failed! App is simulated as not ready for traffic.")
        raise HTTPException(status_code=503, detail="Application not ready")
    return {"status": "ready"}

@app.post('/break-liveness')
def break_liveness():
    """Simulates a fatal application crash for Liveness Probe"""
    APP_STATE['is_alive'] = False
    return {"message": "Liveness broken. Pod should be restarted by Kubernetes soon."}

@app.post('/break-readiness')
def break_readiness():
    """Simulates the app being busy or temporarily unable to serve requests for Readiness Probe"""
    APP_STATE['is_ready'] = False
    return {"message": "Readiness broken. Kubernetes will remove this Pod from the Service load balancer."}

@app.post('/fix-readiness')
def fix_readiness():
    """Restores the readiness state"""
    APP_STATE['is_ready'] = True
    return {"message": "Readiness restored. Kubernetes will start sending traffic again."}

@app.get('/health')
def health_check():
    """Generic health check endpoint."""
    logger.info("Health check performed")
    return {
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat()
    }


@app.post('/api/extract-text')
async def extract_text(file: UploadFile = File(...)):
    """
    Extract text from uploaded PDF file.
    """
    try:
        # Validate file type
        if file.content_type != 'application/pdf':
            raise HTTPException(status_code=400, detail="File must be a PDF")

        # Read file content
        content = await file.read()

        # Extract text from PDF
        pdf_file = BytesIO(content)
        pdf_reader = PyPDF2.PdfReader(pdf_file)

        # Get number of pages
        num_pages = len(pdf_reader.pages)

        # Extract text from all pages
        extracted_text = ""
        for page_num in range(num_pages):
            page = pdf_reader.pages[page_num]
            text = page.extract_text() or ''
            extracted_text += text
            extracted_text += f"\n--- Page {page_num + 1} ---\n"

        logger.info(f"Successfully extracted text from PDF: {file.filename}")

        return {
            'status': 'success',
            'filename': file.filename,
            'text': extracted_text,
            'pages': num_pages,
            'timestamp': datetime.utcnow().isoformat()
        }

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error extracting text from PDF: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error processing PDF: {str(e)}")


@app.get('/api/info')
def get_info():
    """Returns application information."""
    return {
        'application': 'PDF Text Extractor',
        'version': APP_VERSION,
        'environment': APP_ENV,
        'features': ['PDF upload', 'Text extraction', 'Page counting']
    }


if __name__ == "__main__":
    import uvicorn
    port = int(os.getenv("PORT", "8000"))
    logger.info(f"Starting FastAPI (uvicorn) on port {port}")
    uvicorn.run(app, host="0.0.0.0", port=port)

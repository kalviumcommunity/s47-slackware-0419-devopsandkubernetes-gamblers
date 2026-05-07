# PDF Text Extractor - Full Stack Application

A modern full-stack application for extracting text from PDF files. Built with **FastAPI** (backend) and **React** (frontend).

## 📋 Project Structure

```
devopsAndKubernetes/
├── app.py                 # FastAPI backend
├── requirements.txt       # Python dependencies
├── frontend/             # React frontend
│   ├── src/
│   │   ├── main.jsx      # React entry point
│   │   ├── App.jsx       # Main component
│   │   ├── App.css       # Styling
│   │   └── index.css     # Global styles
│   ├── index.html        # HTML template
│   ├── vite.config.js    # Vite configuration
│   ├── package.json      # Node dependencies
│   └── README.md         # Frontend documentation
├── README.md             # This file
└── requirements.txt      # Python dependencies
```

## 🚀 Quick Start

### Prerequisites

- **Python 3.8+** (for backend)
- **Node.js 16+** (for frontend)
- **npm** or **yarn**

### Backend Setup

1. **Install Python dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Run FastAPI server:**
   ```bash
   python -m uvicorn app:app --reload
   ```
   
   The API will be available at `http://localhost:8000`
   - API docs: http://localhost:8000/docs
   - OpenAPI schema: http://localhost:8000/openapi.json

### Frontend Setup

1. **Navigate to frontend directory:**
   ```bash
   cd frontend
   ```

2. **Install dependencies:**
   ```bash
   npm install
   ```

3. **Start development server:**
   ```bash
   npm run dev
   ```
   
   The application will open at `http://localhost:3000`

### Using the Application

1. Open http://localhost:3000 in your browser
2. Click "Choose PDF File" to select a PDF
3. Click "Extract Text" to process the file
4. View the extracted text
5. Use "Copy to Clipboard" to copy the text
6. Click "Clear" to start over

## 🔧 Backend API

### Endpoints

#### Health Check
```
GET /health
```
Returns application health status.

#### Home
```
GET /
```
Returns application information.

#### Extract Text from PDF
```
POST /api/extract-text
```

**Request:**
- Method: `POST`
- Content-Type: `multipart/form-data`
- Parameter: `file` (PDF file)

**Example using curl:**
```bash
curl -X POST "http://localhost:8000/api/extract-text" \
  -F "file=@yourfile.pdf"
```

**Response:**
```json
{
  "status": "success",
  "filename": "document.pdf",
  "text": "Extracted text content...",
  "pages": 5,
  "timestamp": "2024-05-06T10:30:00.000000"
}
```

**Error Response (400):**
```json
{
  "detail": "File must be a PDF"
}
```

#### API Info
```
GET /api/info
```
Returns available features and endpoints.

## 📦 Python Dependencies

- **fastapi** - Modern web framework
- **uvicorn** - ASGI server
- **python-multipart** - File upload support
- **PyPDF2** - PDF text extraction
- **python-cors** - CORS middleware

## 📦 Node Dependencies

- **react** - UI library
- **react-dom** - React rendering
- **axios** - HTTP client
- **vite** - Build tool
- **@vitejs/plugin-react** - React plugin for Vite

## 🔄 Workflow

1. **Upload PDF** → Frontend sends file to backend via `/api/extract-text`
2. **Extract Text** → Backend processes PDF and extracts all text
3. **Return Results** → Backend returns extracted text with metadata
4. **Display** → Frontend shows extracted text with copy functionality

## 🎨 Features

✅ PDF file upload with validation  
✅ Text extraction from all pages  
✅ Page counting  
✅ Copy to clipboard functionality  
✅ Responsive design  
✅ Error handling  
✅ CORS support  
✅ Logging  

## 🐳 Docker Support

Build and run with Docker:

```bash
# Build image
docker build -t pdf-extractor .

# Run container
docker run -p 8000:8000 -p 3000:3000 pdf-extractor
```

## 🧪 Testing the API

### Using FastAPI Swagger UI
Visit http://localhost:8000/docs and use the interactive Swagger UI to test the `/api/extract-text` endpoint.

### Using Python requests
```python
import requests

with open('test.pdf', 'rb') as f:
    files = {'file': f}
    response = requests.post('http://localhost:8000/api/extract-text', files=files)
    print(response.json())
```

## 🔐 CORS Configuration

The backend is configured to accept requests from:
- `http://localhost:3000` (React dev server)
- `http://localhost:8000` (Same origin)
- `http://127.0.0.1:3000` and `http://127.0.0.1:8000`

## 🐛 Troubleshooting

### "Cannot connect to the backend"
- Ensure FastAPI is running: `python -m uvicorn app:app --reload`
- Check that it's running on `http://localhost:8000`
- Verify CORS is properly configured in `app.py`

### "File must be a PDF"
- Ensure you're uploading an actual PDF file
- Check file MIME type

### "Error extracting text from PDF"
- Some PDFs may have corrupted or image-based content
- The extractor works best with text-based PDFs

## 📝 Environment Variables

Set via environment:
```bash
export APP_ENV=production
export APP_VERSION=1.0.0
```

## 🤝 Development

### Backend Development
```bash
# Run with auto-reload
python -m uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

### Frontend Development
```bash
cd frontend
npm run dev
```

### Build for Production
```bash
# Frontend
cd frontend
npm run build

# Backend is ready as-is
```

## 📄 License

MIT License - feel free to use for learning and development.

## 🚀 Next Steps

- Add authentication
- Implement database storage
- Add batch processing
- Implement text search/highlight
- Add PDF preview
- Improve error handling
- Add unit tests
- Deploy to cloud (AWS, GCP, Azure)

---

**Happy PDF extracting!** 📄✨

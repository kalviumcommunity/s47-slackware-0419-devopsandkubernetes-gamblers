# PDF Text Extractor - React Frontend

Modern React frontend for the PDF Text Extractor application.

## Features

- 📄 Upload PDF files
- ⚡ Fast text extraction
- 📋 Copy extracted text to clipboard
- 📱 Responsive design
- 🎨 Beautiful UI with Vite + React

## Prerequisites

- Node.js 16+ and npm
- FastAPI backend running on http://localhost:8000

## Installation

```bash
# Install dependencies
npm install
```

## Development

```bash
# Start development server (http://localhost:3000)
npm run dev
```

The app will automatically proxy API calls to http://localhost:8000

## Build

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

## How to Use

1. Click "Choose PDF File" to select a PDF
2. Click "Extract Text" to process the file
3. View the extracted text
4. Use "Copy to Clipboard" to copy the text
5. Click "Clear" to start over

## API Endpoint

- **POST** `/api/extract-text` - Upload PDF and extract text
  - Request: `multipart/form-data` with `file` field
  - Response: JSON with `text`, `filename`, `pages`, `status`

## Troubleshooting

If you see "Error extracting text from PDF", make sure:
1. The FastAPI backend is running (`python -m uvicorn app:app --reload`)
2. Backend is running on http://localhost:8000
3. CORS is properly configured in the backend

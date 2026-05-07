# 📖 API Documentation - PDF Text Extractor

Complete API reference and usage examples.

## 🔗 Base URL

```
http://localhost:8000
```

## 📝 Endpoints

### 1. GET / - Application Info

Returns basic application information.

**Request:**
```
GET /
```

**Response (200):**
```json
{
  "status": "success",
  "message": "PDF Text Extractor API",
  "version": "1.0.0",
  "environment": "development",
  "timestamp": "2024-05-06T10:30:00.000000"
}
```

---

### 2. GET /health - Health Check

Check if the API is running and healthy.

**Request:**
```
GET /health
```

**Response (200):**
```json
{
  "status": "healthy",
  "timestamp": "2024-05-06T10:30:00.000000"
}
```

---

### 3. POST /api/extract-text - Extract Text from PDF

Extract text content from a PDF file.

**Request:**
```
POST /api/extract-text
Content-Type: multipart/form-data

file: <PDF file binary data>
```

**Parameters:**
| Name | Type | Required | Description |
|------|------|----------|-------------|
| file | File | Yes | PDF file to extract text from |

**Response (200) - Success:**
```json
{
  "status": "success",
  "filename": "document.pdf",
  "text": "Extracted text content from the PDF...\n--- Page 1 ---\n...",
  "pages": 5,
  "timestamp": "2024-05-06T10:30:00.000000"
}
```

**Response (400) - Bad Request:**
```json
{
  "detail": "File must be a PDF"
}
```

**Response (500) - Server Error:**
```json
{
  "detail": "Error processing PDF: [error details]"
}
```

---

### 4. GET /api/info - API Information

Get available features and endpoints.

**Request:**
```
GET /api/info
```

**Response (200):**
```json
{
  "application": "PDF Text Extractor",
  "version": "1.0.0",
  "environment": "development",
  "features": [
    "PDF upload",
    "Text extraction",
    "Page counting"
  ]
}
```

---

## 💻 Usage Examples

### Using cURL

#### Extract text from PDF:
```bash
curl -X POST http://localhost:8000/api/extract-text \
  -F "file=@sample.pdf"
```

#### Extract and save to file:
```bash
curl -X POST http://localhost:8000/api/extract-text \
  -F "file=@sample.pdf" \
  -o response.json
```

#### Pretty print JSON response:
```bash
curl -X POST http://localhost:8000/api/extract-text \
  -F "file=@sample.pdf" | jq .
```

---

### Using Python

#### Using requests library:
```python
import requests

# Upload PDF and extract text
with open('sample.pdf', 'rb') as f:
    files = {'file': f}
    response = requests.post(
        'http://localhost:8000/api/extract-text',
        files=files
    )

# Get the result
if response.status_code == 200:
    result = response.json()
    print(f"Filename: {result['filename']}")
    print(f"Pages: {result['pages']}")
    print(f"Text:\n{result['text']}")
else:
    print(f"Error: {response.json()}")
```

#### With error handling:
```python
import requests
from requests.exceptions import RequestException

def extract_pdf_text(filepath, api_url='http://localhost:8000'):
    try:
        with open(filepath, 'rb') as f:
            files = {'file': f}
            response = requests.post(
                f'{api_url}/api/extract-text',
                files=files,
                timeout=30
            )
            response.raise_for_status()
            return response.json()
    except FileNotFoundError:
        print(f"File not found: {filepath}")
    except RequestException as e:
        print(f"API error: {e}")
    except Exception as e:
        print(f"Error: {e}")

# Usage
result = extract_pdf_text('sample.pdf')
if result:
    print(result['text'])
```

---

### Using JavaScript/Node.js

#### Using axios:
```javascript
const axios = require('axios');
const fs = require('fs');
const FormData = require('form-data');

async function extractPdfText(filePath) {
  try {
    const form = new FormData();
    form.append('file', fs.createReadStream(filePath));

    const response = await axios.post(
      'http://localhost:8000/api/extract-text',
      form,
      {
        headers: form.getHeaders(),
        timeout: 30000
      }
    );

    console.log('Filename:', response.data.filename);
    console.log('Pages:', response.data.pages);
    console.log('Text:', response.data.text);
    return response.data;
  } catch (error) {
    console.error('Error:', error.response?.data || error.message);
  }
}

// Usage
extractPdfText('sample.pdf');
```

#### Using fetch (modern browsers/Node 18+):
```javascript
async function extractPdfText(filePath) {
  try {
    const fileContent = await fs.promises.readFile(filePath);
    const formData = new FormData();
    formData.append('file', new Blob([fileContent], { type: 'application/pdf' }));

    const response = await fetch('http://localhost:8000/api/extract-text', {
      method: 'POST',
      body: formData
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error:', error);
  }
}
```

---

### Using React (Frontend)

#### Component example:
```javascript
import React, { useState } from 'react';
import axios from 'axios';

function PdfUploader() {
  const [file, setFile] = useState(null);
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const handleUpload = async (e) => {
    e.preventDefault();
    if (!file) return;

    setLoading(true);
    setError(null);

    try {
      const formData = new FormData();
      formData.append('file', file);

      const response = await axios.post(
        'http://localhost:8000/api/extract-text',
        formData,
        { headers: { 'Content-Type': 'multipart/form-data' } }
      );

      setResult(response.data);
    } catch (err) {
      setError(err.response?.data?.detail || 'Error uploading file');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <form onSubmit={handleUpload}>
        <input
          type="file"
          accept=".pdf"
          onChange={(e) => setFile(e.target.files[0])}
        />
        <button type="submit" disabled={loading || !file}>
          {loading ? 'Uploading...' : 'Extract Text'}
        </button>
      </form>

      {error && <p style={{ color: 'red' }}>{error}</p>}
      {result && (
        <div>
          <p>File: {result.filename}</p>
          <p>Pages: {result.pages}</p>
          <pre>{result.text}</pre>
        </div>
      )}
    </div>
  );
}
```

---

### Using Postman

1. **Open Postman**
2. **Create new request**
3. **Set method to**: `POST`
4. **Set URL to**: `http://localhost:8000/api/extract-text`
5. **Go to Body tab**
6. **Select**: `form-data`
7. **Add field**:
   - Key: `file`
   - Type: select `File` from dropdown
   - Value: choose your PDF file
8. **Click Send**

---

### Using Swift (iOS)

```swift
import Foundation

func extractPdfText(fileURL: URL) {
    var request = URLRequest(url: URL(string: "http://localhost:8000/api/extract-text")!)
    request.httpMethod = "POST"
    
    let boundary = "Boundary-\(UUID().uuidString)"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
    
    var body = Data()
    body.append("--\(boundary)\r\n".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
    body.append("Content-Type: application/pdf\r\n\r\n".data(using: .utf8)!)
    body.append(try! Data(contentsOf: fileURL))
    body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
    
    request.httpBody = body
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else { return }
        let json = try? JSONDecoder().decode(Response.self, from: data)
        print(json?.text ?? "Error")
    }.resume()
}

struct Response: Codable {
    let status: String
    let filename: String
    let text: String
    let pages: Int
}
```

---

## 🔒 Error Handling

### Common Error Responses

| Status | Error | Solution |
|--------|-------|----------|
| 400 | File must be a PDF | Ensure file is a valid PDF |
| 404 | Endpoint not found | Check the API URL |
| 500 | Error processing PDF | Check PDF format, try another file |
| 503 | Service unavailable | Ensure backend is running |

---

## 🚀 Advanced Usage

### Batch Processing

```python
import requests
import os

def batch_extract(pdf_directory):
    results = []
    for filename in os.listdir(pdf_directory):
        if filename.endswith('.pdf'):
            filepath = os.path.join(pdf_directory, filename)
            with open(filepath, 'rb') as f:
                response = requests.post(
                    'http://localhost:8000/api/extract-text',
                    files={'file': f}
                )
                if response.status_code == 200:
                    results.append(response.json())
    return results

# Usage
results = batch_extract('./pdfs')
for result in results:
    with open(f"{result['filename']}.txt", 'w') as f:
        f.write(result['text'])
```

### Save Text to File

```python
import requests

response = requests.post(
    'http://localhost:8000/api/extract-text',
    files={'file': open('sample.pdf', 'rb')}
)

if response.status_code == 200:
    data = response.json()
    with open('extracted_text.txt', 'w') as f:
        f.write(data['text'])
```

---

## 📊 Response Schema

### Success Response
```typescript
interface SuccessResponse {
  status: "success";
  filename: string;
  text: string;
  pages: number;
  timestamp: string; // ISO 8601 format
}
```

### Error Response
```typescript
interface ErrorResponse {
  detail: string;
}
```

---

## 🎯 Rate Limiting

Currently, there is no rate limiting implemented. For production, consider adding:
- Request throttling
- API keys
- Rate limits per IP/user

---

## 📞 Support

For issues or questions:
1. Check the [SETUP_GUIDE.md](SETUP_GUIDE.md)
2. Review the [QUICK_START.md](QUICK_START.md)
3. Test your request with [Swagger UI](http://localhost:8000/docs)

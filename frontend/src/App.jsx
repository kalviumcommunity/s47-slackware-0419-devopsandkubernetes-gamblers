import React, { useState } from 'react'
import axios from 'axios'
import './App.css'

function App() {
  const [file, setFile] = useState(null)
  const [extractedText, setExtractedText] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const [metadata, setMetadata] = useState(null)

  const handleFileChange = (e) => {
    const selectedFile = e.target.files[0]
    setFile(selectedFile)
    setError('')
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    
    if (!file) {
      setError('Please select a PDF file')
      return
    }

    if (file.type !== 'application/pdf') {
      setError('Please select a valid PDF file')
      return
    }

    setLoading(true)
    setError('')
    setExtractedText('')
    setMetadata(null)

    try {
      const formData = new FormData()
      formData.append('file', file)

      const response = await axios.post(
        'http://localhost:8000/api/extract-text',
        formData,
        {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        }
      )

      setExtractedText(response.data.text)
      setMetadata({
        filename: response.data.filename,
        pages: response.data.pages,
      })
    } catch (err) {
      setError(
        err.response?.data?.detail ||
        'Error extracting text from PDF. Make sure the FastAPI server is running on http://localhost:8000'
      )
    } finally {
      setLoading(false)
    }
  }

  const handleClear = () => {
    setFile(null)
    setExtractedText('')
    setMetadata(null)
    setError('')
  }

  const handleCopyToClipboard = () => {
    navigator.clipboard.writeText(extractedText)
    alert('Text copied to clipboard!')
  }

  return (
    <div className="container">
      <div className="card">
        <h1>📄 PDF Text Extractor</h1>
        <p className="subtitle">Extract text from PDF files instantly</p>

        <form onSubmit={handleSubmit} className="upload-form">
          <div className="file-input-wrapper">
            <label htmlFor="file-input" className="file-label">
              Choose PDF File
            </label>
            <input
              id="file-input"
              type="file"
              accept=".pdf"
              onChange={handleFileChange}
              className="file-input"
              disabled={loading}
            />
            {file && <span className="file-name">{file.name}</span>}
          </div>

          <div className="button-group">
            <button type="submit" className="btn btn-primary" disabled={loading || !file}>
              {loading ? 'Extracting...' : 'Extract Text'}
            </button>
            {extractedText && (
              <button type="button" className="btn btn-secondary" onClick={handleClear}>
                Clear
              </button>
            )}
          </div>
        </form>

        {error && <div className="error-message">{error}</div>}

        {metadata && (
          <div className="metadata">
            <p><strong>File:</strong> {metadata.filename}</p>
            <p><strong>Pages:</strong> {metadata.pages}</p>
          </div>
        )}

        {extractedText && (
          <div className="text-output-wrapper">
            <div className="text-output-header">
              <h2>Extracted Text</h2>
              <button
                type="button"
                className="btn btn-small"
                onClick={handleCopyToClipboard}
              >
                Copy to Clipboard
              </button>
            </div>
            <pre className="text-output">{extractedText}</pre>
          </div>
        )}
      </div>
    </div>
  )
}

export default App

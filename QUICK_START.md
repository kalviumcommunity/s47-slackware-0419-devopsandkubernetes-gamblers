# 🚀 Quick Start Guide - PDF Text Extractor

Get the application up and running in 5 minutes!

## ⚡ Option 1: Fastest Way (Recommended)

### Windows Users
1. Double-click `setup.bat`
2. In the first terminal that opens, run:
   ```
   python -m uvicorn app:app --reload
   ```
3. In a second terminal, navigate to `frontend` and run:
   ```
   cd frontend
   npm run dev
   ```
4. Open http://localhost:3000 in your browser

### macOS/Linux Users
1. Run in terminal:
   ```bash
   bash setup.sh
   ```
2. In the first terminal, run:
   ```bash
   python -m uvicorn app:app --reload
   ```
3. In a second terminal, run:
   ```bash
   cd frontend && npm run dev
   ```
4. Open http://localhost:3000 in your browser

## ⚡ Option 2: Using One Command

### Windows
```cmd
start-app.bat
```

### macOS/Linux
```bash
bash start-app.sh
```

This will automatically open two terminals with both services running.

## ⚡ Option 3: Docker (if you have Docker installed)

### Single Command
```bash
docker-compose up --build
```

Access the app at:
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Docs: http://localhost:8000/docs

## 📋 Manual Setup

### Step 1: Install Backend Dependencies
```bash
pip install -r requirements.txt
```

### Step 2: Start Backend
```bash
python -m uvicorn app:app --reload
```
✓ Backend running at: http://localhost:8000

### Step 3: Install Frontend Dependencies
```bash
cd frontend
npm install
```

### Step 4: Start Frontend
```bash
npm run dev
```
✓ Frontend running at: http://localhost:3000

## 🎯 Using the Application

1. **Open** http://localhost:3000
2. **Click** "Choose PDF File"
3. **Select** a PDF from your computer
4. **Click** "Extract Text"
5. **View** the extracted text
6. **Copy** text using "Copy to Clipboard" button

## 🔍 Testing the API

### Swagger UI (Interactive)
Visit: http://localhost:8000/docs

### Using curl
```bash
curl -F "file=@sample.pdf" http://localhost:8000/api/extract-text
```

### Using Python
```python
import requests

with open('sample.pdf', 'rb') as f:
    response = requests.post(
        'http://localhost:8000/api/extract-text',
        files={'file': f}
    )
    print(response.json())
```

## 📊 Available Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/` | Application info |
| GET | `/health` | Health check |
| POST | `/api/extract-text` | Extract text from PDF |
| GET | `/api/info` | API features |

## 🐛 Troubleshooting

### "ModuleNotFoundError: No module named 'fastapi'"
```bash
pip install -r requirements.txt
```

### "npm: command not found"
Install Node.js from https://nodejs.org/

### "Cannot connect to backend"
- Check backend is running: http://localhost:8000
- Check port 8000 is not blocked
- Try: `python -m uvicorn app:app --reload`

### "Port 8000 already in use"
```bash
# Find and kill process on port 8000
# Windows:
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# macOS/Linux:
lsof -i :8000
kill -9 <PID>
```

### "Port 3000 already in use"
```bash
# Similar process, but for port 3000
```

## 📚 Documentation Files

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Comprehensive setup documentation
- **[frontend/README.md](frontend/README.md)** - React frontend docs
- **[requirements.txt](requirements.txt)** - Python dependencies
- **[Dockerfile](Dockerfile)** - Docker configuration
- **[docker-compose.yml](docker-compose.yml)** - Docker Compose setup

## 🔄 Development Tips

### Hot Reload
Both frontend and backend support hot reload:
- **Backend**: Changes to `app.py` automatically reload
- **Frontend**: Changes to React files automatically refresh

### API Documentation
Swagger UI is available at: http://localhost:8000/docs
ReDoc is available at: http://localhost:8000/redoc

### Testing PDFs
Use any PDF file. For testing, you can:
1. Use sample PDFs from the web
2. Convert documents to PDF
3. Use online PDF generators

## 🚀 Production Deployment

### Build Frontend
```bash
cd frontend
npm run build
```

### Run with Production Server
```bash
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:8000 app:app
```

### Build Docker Image
```bash
docker build -t pdf-extractor .
docker run -p 8000:8000 pdf-extractor
```

## 📞 Need Help?

1. Check the [SETUP_GUIDE.md](SETUP_GUIDE.md) for detailed information
2. Review error messages carefully - they usually indicate the issue
3. Verify all prerequisites are installed
4. Check that ports 8000 and 3000 are available

## ✅ Success Checklist

- [ ] Python 3.8+ installed
- [ ] Node.js 16+ installed
- [ ] pip install successful
- [ ] npm install successful
- [ ] Backend running on port 8000
- [ ] Frontend running on port 3000
- [ ] Can access http://localhost:3000
- [ ] Can upload and extract PDF text

---

**You're all set!** 🎉 Start extracting text from PDFs now!

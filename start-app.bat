@echo off
REM Start both backend and frontend servers

echo Starting PDF Text Extractor Application...
echo.
echo This script will start:
echo 1. FastAPI Backend (port 8000)
echo 2. React Frontend (port 3000)
echo.

REM Start backend in a new window
echo Starting backend...
start "PDF Extractor - Backend" cmd /k "python -m uvicorn app:app --reload"

REM Wait a moment for backend to start
timeout /t 2 /nobreak

REM Start frontend in a new window
echo Starting frontend...
cd frontend
start "PDF Extractor - Frontend" cmd /k "npm run dev"
cd ..

echo.
echo ===================================
echo Services Started!
echo ===================================
echo.
echo Backend: http://localhost:8000
echo API Docs: http://localhost:8000/docs
echo Frontend: http://localhost:3000
echo.
echo Press any key to close this window...
pause

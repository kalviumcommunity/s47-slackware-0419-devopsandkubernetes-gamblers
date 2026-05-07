@echo off
REM Quick Start Script for PDF Text Extractor (Windows)
REM This script sets up and runs both backend and frontend

echo ================================
echo PDF Text Extractor - Quick Start
echo ================================
echo.

REM Check Python
echo Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo Python is not installed. Please install Python 3.8+.
    exit /b 1
)
echo Python found:
python --version

REM Check Node
echo Checking Node.js installation...
node --version >nul 2>&1
if errorlevel 1 (
    echo Node.js is not installed. Please install Node.js 16+.
    exit /b 1
)
echo Node.js found:
node --version

REM Install backend dependencies
echo.
echo Installing backend dependencies...
pip install -r requirements.txt

REM Install frontend dependencies
echo.
echo Installing frontend dependencies...
cd frontend
call npm install
cd ..

echo.
echo ================================
echo Setup Complete!
echo ================================
echo.
echo To start the application:
echo.
echo Terminal 1 - Run FastAPI backend:
echo   python -m uvicorn app:app --reload
echo.
echo Terminal 2 - Run React frontend:
echo   cd frontend ^& npm run dev
echo.
echo Then open http://localhost:3000 in your browser
echo.
echo API Documentation: http://localhost:8000/docs
echo.
pause

#!/bin/bash

# Quick Start Script for PDF Text Extractor
# This script sets up and runs both backend and frontend

echo "================================"
echo "PDF Text Extractor - Quick Start"
echo "================================"
echo ""

# Check Python
echo "Checking Python installation..."
if ! command -v python3 &> /dev/null; then
    echo "Python 3 is not installed. Please install Python 3.8+."
    exit 1
fi
echo "✓ Python $(python3 --version | awk '{print $2}') found"

# Check Node
echo "Checking Node.js installation..."
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js 16+."
    exit 1
fi
echo "✓ Node.js $(node --version) found"

# Install backend dependencies
echo ""
echo "Installing backend dependencies..."
pip install -r requirements.txt

# Install frontend dependencies
echo ""
echo "Installing frontend dependencies..."
cd frontend
npm install
cd ..

echo ""
echo "================================"
echo "Setup Complete!"
echo "================================"
echo ""
echo "To start the application:"
echo ""
echo "Terminal 1 - Run FastAPI backend:"
echo "  python -m uvicorn app:app --reload"
echo ""
echo "Terminal 2 - Run React frontend:"
echo "  cd frontend && npm run dev"
echo ""
echo "Then open http://localhost:3000 in your browser"
echo ""
echo "API Documentation: http://localhost:8000/docs"
echo ""

#!/bin/bash

# Start both backend and frontend servers

echo "Starting PDF Text Extractor Application..."
echo ""
echo "This script will start:"
echo "1. FastAPI Backend (port 8000)"
echo "2. React Frontend (port 3000)"
echo ""

# Start backend in the background
echo "Starting backend..."
python -m uvicorn app:app --reload &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 2

# Start frontend in the background
echo "Starting frontend..."
cd frontend
npm run dev &
FRONTEND_PID=$!
cd ..

echo ""
echo "==================================="
echo "Services Started!"
echo "==================================="
echo ""
echo "Backend: http://localhost:8000"
echo "API Docs: http://localhost:8000/docs"
echo "Frontend: http://localhost:3000"
echo ""
echo "Backend PID: $BACKEND_PID"
echo "Frontend PID: $FRONTEND_PID"
echo ""
echo "To stop the services, run:"
echo "  kill $BACKEND_PID $FRONTEND_PID"
echo ""
echo "Press Ctrl+C to stop..."

# Wait for both processes
wait $BACKEND_PID $FRONTEND_PID

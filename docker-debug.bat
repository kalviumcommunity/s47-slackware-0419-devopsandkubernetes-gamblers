@echo off
REM Build and run using docker-compose (Windows)
echo Building images (no cache)...
docker-compose build --no-cache

echo Starting services...
docker-compose up -d

echo Tailing backend and frontend logs (press Ctrl+C to exit)...
docker-compose logs -f backend frontend
pause

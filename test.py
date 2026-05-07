#!/usr/bin/env python3
"""
Test script for PDF Text Extractor
Verifies that all components are working correctly
"""

import sys
import subprocess
import json
from pathlib import Path

def check_python():
    """Check Python version"""
    print("✓ Python version:", sys.version.split()[0])
    if sys.version_info < (3, 8):
        print("✗ Python 3.8+ required")
        return False
    return True

def check_imports():
    """Check if required packages are installed"""
    packages = {
        'fastapi': 'FastAPI',
        'uvicorn': 'Uvicorn',
        'PyPDF2': 'PyPDF2',
        'fastapi.middleware.cors': 'CORS',
    }
    
    all_ok = True
    for module, name in packages.items():
        try:
            __import__(module)
            print(f"✓ {name} installed")
        except ImportError:
            print(f"✗ {name} not installed")
            all_ok = False
    
    return all_ok

def check_files():
    """Check if required files exist"""
    required_files = [
        'app.py',
        'requirements.txt',
        'frontend/package.json',
        'frontend/src/App.jsx',
    ]
    
    all_ok = True
    for filepath in required_files:
        if Path(filepath).exists():
            print(f"✓ {filepath} exists")
        else:
            print(f"✗ {filepath} missing")
            all_ok = False
    
    return all_ok

def check_api():
    """Try to connect to API"""
    try:
        import requests
        response = requests.get('http://localhost:8000/health', timeout=2)
        if response.status_code == 200:
            print("✓ API is running and healthy")
            return True
        else:
            print("✗ API returned status:", response.status_code)
            return False
    except Exception as e:
        print(f"✗ Cannot connect to API: {str(e)}")
        return False

def main():
    print("\n" + "="*50)
    print("PDF TEXT EXTRACTOR - DIAGNOSTIC TEST")
    print("="*50 + "\n")
    
    print("1. Checking Python environment...")
    python_ok = check_python()
    
    print("\n2. Checking installed packages...")
    imports_ok = check_imports()
    
    print("\n3. Checking project files...")
    files_ok = check_files()
    
    print("\n4. Checking API connectivity...")
    api_ok = check_api()
    
    print("\n" + "="*50)
    print("RESULTS:")
    print("="*50)
    print(f"Python:       {'✓ OK' if python_ok else '✗ FAILED'}")
    print(f"Packages:     {'✓ OK' if imports_ok else '✗ FAILED'}")
    print(f"Files:        {'✓ OK' if files_ok else '✗ FAILED'}")
    print(f"API:          {'✓ OK' if api_ok else '⚠ NOT RUNNING (expected if server not started)'}")
    print("="*50 + "\n")
    
    if python_ok and imports_ok and files_ok:
        print("✓ Project setup is correct!")
        print("\nTo start the application:")
        print("  1. Terminal 1: python -m uvicorn app:app --reload")
        print("  2. Terminal 2: cd frontend && npm run dev")
        print("  3. Open: http://localhost:3000")
    else:
        print("✗ Some checks failed. Please fix the issues above.")
        if not imports_ok:
            print("\nInstall missing packages with:")
            print("  pip install -r requirements.txt")

if __name__ == '__main__':
    main()

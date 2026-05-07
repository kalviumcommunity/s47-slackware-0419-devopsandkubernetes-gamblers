# Container Debugging Notes

This document records the container-related issues I encountered while building and running this project locally, the debugging steps I took, and the fixes applied.

Summary of issues discovered

- pip install failed during image build because `PyPDF2` was pinned to a non-existent/unpublished version (`PyPDF2==3.17.1`).
- `uvicorn` crash on start due to leftover Flask code in `app.py` (SyntaxError: `return` outside function).
- When running via Docker Compose with the runtime image creating a non-root `appuser`, mounting the host directory into `/app` overwrote the virtualenv and files in the image, which can produce permission and missing-dependency errors at runtime.

What I changed in this repository

- Fixed `requirements.txt` to use a valid `PyPDF2` release and removed an invalid `python-cors` entry.
  - File: `requirements.txt`
- Removed leftover Flask code and replaced it with a clean FastAPI-only startup in `app.py`.
  - File: `app.py`
- Updated `docker-compose.yml` for a local-debugging profile to avoid common permission/volume issues:
  - Run backend as `root` during local development to avoid permission errors when mounting host sources
  - Enable `--reload` in uvicorn for live editing inside the container
  - Added `DEV_MODE` environment variable to clearly indicate development-mode override
  - File: `docker-compose.yml`
- Added debugging helper files to reproduce the build/run flow and capture logs locally:
  - `docker-debug.sh` (Linux/macOS)
  - `docker-debug.bat` (Windows)
- Added this `DOCKER_DEBUG.md` explaining the issues and fixes so reviewers can follow the debugging steps.
- Added `PR_NOTES.md` describing what should be included in the PR and how to validate the fix locally.

Reproduction steps (what I ran locally)

1. Build and run with docker-compose (no cache to ensure fresh environment):

```bash
# from project root
docker-compose build --no-cache
docker-compose up -d
```

2. Tail logs to observe failures:

```bash
docker-compose logs -f backend
```

Observed errors (examples)

- pip install failure during build:
```
ERROR: No matching distribution found for PyPDF2==3.17.1
```

- uvicorn startup crash (before fix):
```
SyntaxError: 'return' outside function
  File "app.py", line 143
    return jsonify({
    ^^
SyntaxError: 'return' outside function
```

Diagnosis & Fixes

1. PyPDF2 version pinned incorrectly
   - Diagnosis: `pip` reported that version 3.17.1 doesn't exist on PyPI.
   - Fix: Update `requirements.txt` to a valid version (set to `PyPDF2==3.0.1`).

2. Mixed Flask / FastAPI code caused syntax errors
   - Diagnosis: `app.py` had residual Flask routes and `if __name__ == '__main__'` blocks that used `return jsonify(...)` outside FastAPI handlers.
   - Fix: Replace `app.py` contents with a clean FastAPI app using `uvicorn` as the entrypoint.

3. Volume mounts and non-root runtime user caused permission / missing dependency issues
   - Diagnosis: The production Dockerfile was designed to copy a virtualenv from builder into the final image and run as non-root. Mounting the host `.` into `/app` at runtime hides the copied virtualenv and may produce "module not found" errors inside the container; additionally, UID/GID mismatches can prevent the non-root user accessing mounted files.
   - Fix: For local debugging we set `user: root` in `docker-compose.yml` and mount with `:rw`. This is **only** for local development; production images should not run as root and should not mount host code.

Validation steps (what a reviewer should run)

1. From repo root:
```bash
# Build and run
docker-compose build --no-cache
docker-compose up -d

# Tail backend logs
docker-compose logs -f backend
```

2. Verify backend health endpoint is reachable:
```bash
curl http://localhost:8000/health
# Expected: {"status":"healthy","timestamp":"..."}
```

3. Test PDF extraction (once backend healthy):
```bash
curl -F "file=@sample.pdf" http://localhost:8000/api/extract-text
```

Notes and caveats

- The `user: root` change in `docker-compose.yml` is intended only for local debugging; for a production PR we can provide a `docker-compose.override.yml` or a Makefile target that sets this for local testing only.
- If you prefer not to run containers as root locally, an alternative is to ensure the container's runtime user has the same UID/GID as your host user and avoid copying the venv into the image (use system-wide installs or rebuild dependencies inside the running container).

Files changed in this patchset

- `requirements.txt` — pinned to valid PyPI versions
- `app.py` — cleaned to be FastAPI-only
- `docker-compose.yml` — local-debug adjustments (user=root, reload)
- `DOCKER_DEBUG.md` — this file (debugging notes)
- `docker-debug.sh` and `docker-debug.bat` — helper scripts to build/run/tail logs
- `PR_NOTES.md` — instructions for PR description and validation

If you'd like, I can now:
- Create a suggested PR description and a commit message set for the changes I made
- Add a `docker-compose.override.yml` that contains the `user: root` override so the main compose remains production-friendly
- Help record the demo script that you can follow when recording your screen-share video


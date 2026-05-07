# PR Notes - Container Debugging Contribution

This PR contains changes intended to demonstrate container debugging and fixes. Include the following information in the PR description when submitting:

1. Problem statement
   - Briefly describe the errors observed during `docker-compose build` and `docker-compose up`.
   - Example errors: `No matching distribution found for PyPDF2==3.17.1`, `SyntaxError: 'return' outside function` from `uvicorn`.

2. Reproduction steps
   - Commands to reproduce locally (see `DOCKER_DEBUG.md`):
     ```bash
     docker-compose build --no-cache
     docker-compose up -d
     docker-compose logs -f backend
     ```

3. What I changed
   - `requirements.txt` — corrected `PyPDF2` pin and removed invalid package
   - `app.py` — removed mixed Flask/FastAPI code and provided clean FastAPI app
   - `docker-compose.yml` — adjusted for local debugging (user=root; --reload)
   - Added `DOCKER_DEBUG.md`, `docker-debug.sh`, `docker-debug.bat` and `PR_NOTES.md` to document the flow

4. Verification checklist for reviewers
   - [ ] `docker-compose build --no-cache` completes successfully
   - [ ] `docker-compose up -d` starts backend and frontend services
   - [ ] `curl http://localhost:8000/health` returns healthy JSON
   - [ ] `curl -F "file=@sample.pdf" http://localhost:8000/api/extract-text` returns extracted text JSON

5. Notes about the `user: root` change
   - This is intentionally added for **local debugging** to avoid permission issues when the host directory is mounted into the container.
   - For production, revert this change or provide a dedicated `docker-compose.override.yml` that is only used by developers.

6. Suggested commit message

```
fix(container): resolve local container build/run errors

- pin valid PyPDF2 version in requirements.txt
- remove leftover Flask code and simplify app.py to FastAPI
- make docker-compose developer-friendly to avoid mount/permission issues
- add DOCKER_DEBUG.md and run scripts for reproduction and logs
```

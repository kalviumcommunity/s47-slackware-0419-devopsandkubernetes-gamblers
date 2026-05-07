# Externalized Configuration Guide & Video Script

This document details how our Kubernetes deployment externalizes configuration using `ConfigMaps` and `Secrets`, and provides a script for your video demo assignment.

## What Was Changed
1. **ConfigMap (`k8s/configmap.yaml`)**: We added `LOG_LEVEL` to control the application's logging verbosity without changing code.
2. **Secret (`k8s/secret.yaml`)**: We are injecting `API_KEY` and `DB_PASSWORD` securely.
3. **Application (`app.py`)**: The FastAPI app now reads these values from the environment. It uses `LOG_LEVEL` to configure the Python logger and protects a new `/api/secure-info` endpoint using the `API_KEY`.
4. **Deployment (`k8s/backend-deployment.yaml`)**: Modified to map the ConfigMap and Secret keys into the container's environment variables.

---

## Video Demo Script

**[Screen Recording: Show your IDE with `k8s/configmap.yaml` and `k8s/secret.yaml` open]**

**Speaker**: "Hello, in this demo I'll show how I externalized configuration for the PDF Extractor application using Kubernetes ConfigMaps and Secrets."

**[Point to the ConfigMap]**
**Speaker**: "First, we have our `ConfigMap`. This stores non-sensitive configuration data like the `APP_ENV`, `APP_VERSION`, and a newly added `LOG_LEVEL`. This allows us to change how verbose the application logging is without needing to rebuild the Docker image."

**[Point to the Secret]**
**Speaker**: "Next, we have our `Secret`. This stores sensitive data, specifically our `DB_PASSWORD` and an `API_KEY`. Unlike ConfigMaps, Secrets are encoded (and ideally encrypted at rest by Kubernetes), preventing credentials from being exposed in our plain-text source code."

**[Screen Recording: Open `k8s/backend-deployment.yaml`]**

**Speaker**: "To consume these, we map them into our Pods as environment variables in our Deployment manifest. Using `valueFrom: configMapKeyRef` and `valueFrom: secretKeyRef`, Kubernetes securely injects these values directly into the container's runtime environment."

**[Screen Recording: Open terminal and run `kubectl apply -f k8s/configmap.yaml -f k8s/secret.yaml -f k8s/backend-deployment.yaml`]**

**Speaker**: "I'm applying these changes to my local cluster now."

**[Screen Recording: Show a terminal using `curl` or Postman]**

**Speaker**: "To prove the application is consuming these, I created a secure endpoint. If I try to access `/api/secure-info` without a key, it fails."
*(Run: `curl -I http://localhost:8000/api/secure-info` - Show 401 Unauthorized)*

**Speaker**: "But if I pass the `API_KEY` we defined in our Secret via the header..."
*(Run: `curl -H "x-api-key: abc-123-api-key" http://localhost:8000/api/secure-info` - Show success JSON)*
**Speaker**: "...the application successfully reads the injected Secret, validates it, and grants access."

**[Screen Recording: Back to camera/presentation]**

**Speaker**: "Why is this approach safer and more flexible?
1. **Security**: We never hardcode passwords in Git.
2. **Flexibility**: We can deploy the exact same Docker image to Development, Staging, and Production simply by swapping out the ConfigMap and Secret applied to the cluster.
Thank you."

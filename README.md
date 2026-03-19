# ISET Docker Image

This repository provides a Docker-based build environment for the **ISET** project, allowing you to generate a runnable container **without exposing the source code**.

---

## 📦 Overview

- The ISET source code is **NOT included** in this repository
- You must provide the source code locally
- The Docker image will:
  - build ISET
  - package the executable
  - generate a minimal runtime environment
  - use Intel MKL (PARDISO) as the default solver

---

## 📁 Requirements

Before building the image, you must have:

- Docker installed
- Access to the **ISET source code**

---

## 🚀 How to Build

Instead of copying the ISET source into this repository, you will use it as the **Docker build context**.

### Step 1 — Go to this repository

```bash
cd iset-docker
```

### Step 2 — Run the build command

```bash
docker build -t iset:latest -f Dockerfile /path/to/ISET
```

> 🔁 Replace `/path/to/ISET` with the actual path to your ISET source code

---

## 🧠 How It Works
- `/path/to/ISET` becomes the build context
- The Dockerfile copies the source internally
- The build happens inside the container
- The final image contains only:
    - the compiled executable
    - required runtime libraries
---

## ▶️ Running the Container
After building:

```bash
docker run -it iset:latest
```
---

## ⚠️ Important Notes

### 1. Source Code is Required
This repository does NOT include ISET.

You must provide it yourself:

```bash
docker build -f Dockerfile -t iset:latest /your/local/ISET
```

### 2. No Source Code in Final Image

The final Docker image:
- does NOT include the ISET source
- only includes compiled artifacts

### 3. Solver Configuration

The default build uses:
- PARDISO (Intel MKL)

Future versions may support:
- MUMPS (via build arguments, creating separate images, i.e., `iset:pardiso`, `iset:mumps`)
- CHOLMOD (via build arguments, creating separate images, i.e., `iset:pardiso`, `iset:cholmod`)

### 4. Image Size

Because Intel MKL is used by default, the image may be large.

---

## 🛠️ Troubleshooting

### Build fails
- Check if the ISET path is correct
- Ensure required directories exist:
    - SetSolver/
    - SciEng/

---

### Runtime errors (missing libraries)

Run inside the container:

```bash
ldd tcliset
```

---

📌 Future Improvements

- Support for multiple solvers via build arguments
- GitHub Actions for automated builds
- Reduced runtime image size

<!-- ---

## 👨‍💻 Maintainer

LabMeC / ISET Dockerization effort -->
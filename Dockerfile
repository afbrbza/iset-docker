# =========================
# STAGE 1: BUILDER
# =========================
FROM debian:trixie-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    gfortran \
    cmake \
    ninja-build \
    git \
    wget \
    gpg \
    ca-certificates \
    tcl-dev \
    tcl \
    libopenblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

# ---- Intel MKL (PARDISO) ----
RUN apt-get update -qq && apt-get install -qq -y wget gpg ca-certificates && \
    wget -qO- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
        | gpg --dearmor -o /usr/share/keyrings/intel-oneapi-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/intel-oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
        > /etc/apt/sources.list.d/oneAPI.list && \
    apt-get update -qq && \
    apt-get install -qq -y intel-oneapi-mkl-devel && \
    rm -rf /var/lib/apt/lists/*

# ---- carregar ambiente MKL ----
ENV MKLROOT=/opt/intel/oneapi/mkl/latest
ENV LD_LIBRARY_PATH=$MKLROOT/lib/intel64:$LD_LIBRARY_PATH

WORKDIR /app

# IMPORTANTE: depende do build context
COPY ISET/ /app

# ---- build ISET (PARDISO) ----
RUN mkdir build && cd build && \
    cmake \
      -G Ninja \
      -DCMAKE_BUILD_TYPE=Release \
      -DISET_USE_MUMPS=OFF \
      -DISET_USE_CHOLMOD=OFF \
      -DISET_USE_PARDISO_MKL=ON \
      -DISET_USE_MKL_BLAS=ON \
      -DISET_USE_METIS=OFF \
      -DISET_USE_CGAL=OFF \
      -S /app/SetSolver \
      -B /app/build && \
    cmake --build /app/build -j$(nproc)

# =========================
# STAGE 2: RUNTIME
# =========================
FROM debian:trixie-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libgfortran5 \
    libgomp1 \
    tcl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# ---- MKL runtime ----
RUN apt-get update -qq && apt-get install -qq -y wget gpg ca-certificates && \
    wget -qO- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
        | gpg --dearmor -o /usr/share/keyrings/intel-oneapi-archive-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/intel-oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
        > /etc/apt/sources.list.d/oneAPI.list && \
    apt-get update -qq && \
    apt-get install -qq -y intel-oneapi-mkl-runtime && \
    rm -rf /var/lib/apt/lists/*

ENV MKLROOT=/opt/intel/oneapi/mkl/latest
ENV LD_LIBRARY_PATH=$MKLROOT/lib/intel64:$LD_LIBRARY_PATH

WORKDIR /app

# executável
COPY --from=builder /app/build/projects/tclmain/tcliset .

# arquivos auxiliares
COPY --from=builder /app/build/projects/tclmain/*.tcl .
COPY --from=builder /app/build/projects/tclmain/*.grf .

CMD ["./tcliset"]
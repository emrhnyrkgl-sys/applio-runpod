FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && apt-get install -y \
    git \
    ffmpeg \
    wget \
    curl \
    ca-certificates \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python-is-python3 \
    build-essential \
    libportaudio2 \
    portaudio19-dev \
    libasound2-dev \
    iproute2 \
    procps \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --break-system-packages uv

WORKDIR /opt

RUN git clone https://github.com/IAHispano/Applio.git /opt/Applio

WORKDIR /opt/Applio

RUN chmod +x run-install.sh run-applio.sh && ./run-install.sh

RUN . .venv/bin/activate && \
    uv pip install --reinstall --index-url https://download.pytorch.org/whl/cu128 torch torchvision torchaudio

RUN wget -q https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

COPY start-applio.sh /usr/local/bin/start-applio.sh

RUN chmod +x /usr/local/bin/start-applio.sh

EXPOSE 6969

CMD ["/usr/local/bin/start-applio.sh"]

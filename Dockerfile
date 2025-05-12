# ベースイメージを選択 (PyTorch 2.1以上と互換性のあるCUDAバージョンを含む)
# 例: CUDA 12.1.1 + cuDNN 8 を含む Ubuntu 22.04 ベース
# Docker Hub (hub.docker.com/r/nvidia/cuda) で適切なイメージを探してください
# お使いのGPUドライバ、Docker Desktop/WSL2環境との互換性も考慮してください
FROM nvidia/cuda:12.1.1-cudnn8-devel-ubuntu22.04

# 環境変数設定 (文字化け防止など)
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive

# 必要なパッケージのインストール
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3.10 \
    python3-pip \
    python3.10-venv \
    libsndfile1 \
    # その他、学習に必要な可能性のあるパッケージがあれば追記
    && rm -rf /var/lib/apt/lists/*

# Python 3.10 と pip3 は Ubuntu 22.04 でデフォルトになっているため追加設定は不要

# 作業ディレクトリ作成 & 設定
WORKDIR /app

# Python仮想環境の作成と有効化 (推奨)
RUN python3 -m venv /app/venv
ENV PATH="/app/venv/bin:$PATH"

# 必要なPythonライブラリのインストール
# まずpipとsetuptoolsをアップグレード
RUN pip install --no-cache-dir --upgrade pip setuptools

# PyTorchのインストール (CUDA 12.1 対応版)
# 公式サイト(pytorch.org)でCUDAバージョンに合ったコマンドを確認してください
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# HydraとWandB (READMEで使用が示唆されているライブラリ)
RUN pip install --no-cache-dir hydra-core wandb

# リポジトリのコードをコピー
COPY . .

# requirements.txt がもしあれば、それを使ってインストール (コメントアウトされています)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# （オプション）その他の依存ライブラリがあればここに追加
# RUN pip install --no-cache-dir ...

# コンテナ実行時のデフォルト設定 (ここでは設定せず、docker run時に指定)
# ENTRYPOINT ["python3"]
# CMD ["src/train.py"]
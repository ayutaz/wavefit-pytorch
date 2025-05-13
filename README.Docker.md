# Docker環境にて学習を行う

## コンテナのビルド

```bash
docker build -t wavefit-train-env .
```

## コンテナの実行

```bash
docker run --gpus all --rm -it `
  -v "${env:ROOT_DIR_HOST}:${env:ROOT_DIR_CONT}" `
  -v "${env:DATASET_DIR_HOST}:${env:DATASET_DIR_CONT}" `
  -w "${env:ROOT_DIR_CONT}" `
  wavefit-train-env bash
```

## データセットの準備 (LibriTTS 等)

コンテナ内で `setup_dataset_inside_container.sh` を実行すると、LibriTTS コーパスを自動でダウンロード・展開できます。

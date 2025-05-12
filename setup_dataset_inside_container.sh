#!/bin/bash

set -e # エラーが発生したらスクリプトを終了

DATASET_TARGET_DIR="/data" # docker-compose.ymlでマウントしたパス
DOWNLOAD_CACHE_DIR="${DATASET_TARGET_DIR}/_downloads" # アーカイブ一時保存場所
LIBRI_TTS_BASE_URL="http://www.openslr.org/resources/60/"

# ダウンロード・展開したいLibriTTSのパート
# 必要に応じてリストを編集してください
LIBRI_TTS_PARTS=("train-clean-100" "test-clean")
# LIBRI_TTS_PARTS=("train-clean-100" "train-clean-360" "test-clean" "dev-clean") # フルセットの例

echo "--- Checking and Preparing Datasets in Container ---"

# 必要なツールがなければインストール
if ! command -v wget &> /dev/null || ! command -v tar &> /dev/null; then
    echo "wget or tar not found. Installing required tools..."
    apt-get update && apt-get install -y wget tar
fi

mkdir -p "${DOWNLOAD_CACHE_DIR}"
cd "${DATASET_TARGET_DIR}" || exit 1 # /data に移動、失敗したら終了

for part in "${LIBRI_TTS_PARTS[@]}"; do
    # LibriTTSは展開すると 'LibriTTS/' というサブディレクトリができることが多いので、
    # 実際の音声データがあるディレクトリパスを想定
    expected_data_path="${DATASET_TARGET_DIR}/${part}" # もし 'LibriTTS' サブディレクトリがなければこちら
    # もし 'LibriTTS' サブディレクトリが出来る場合:
    # expected_data_path="${DATASET_TARGET_DIR}/LibriTTS/${part}"

    if [ -d "${expected_data_path}" ]; then
        echo "[OK] Dataset part '${part}' already exists at ${expected_data_path}. Skipping."
    else
        echo "[Action Required] Dataset part '${part}' not found. Preparing..."
        archive_file="${part}.tar.gz"
        archive_path="${DOWNLOAD_CACHE_DIR}/${archive_file}"
        download_url="${LIBRI_TTS_BASE_URL}${archive_file}"

        if [ ! -f "${archive_path}" ]; then
            echo "Downloading ${archive_file} from ${download_url} ..."
            echo "(This may take a long time...)"
            wget -P "${DOWNLOAD_CACHE_DIR}" "${download_url}"
            echo "Download complete: ${archive_path}"
        else
            echo "Archive file ${archive_path} already exists. Skipping download."
        fi

        echo "Extracting ${archive_path} to ${DATASET_TARGET_DIR} ..."
        echo "(This may also take a long time...)"
        # tar はカレントディレクトリ (DATASET_TARGET_DIR) に展開する
        tar -xzf "${archive_path}" -C "${DATASET_TARGET_DIR}"
        echo "Extraction complete for '${part}'."

        # オプション: 展開後にアーカイブを削除
        # echo "Removing archive file ${archive_path}."
        # rm "${archive_path}"
    fi
done

echo "--- Dataset preparation finished ---"
echo "Dataset directory (/data) contents:"
ls -l "${DATASET_TARGET_DIR}"
echo "Please check if the directory structure (e.g., /data/train-clean-100/...) is as expected by your training script."
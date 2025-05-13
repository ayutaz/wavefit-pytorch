# --- 環境変数とパラメータ設定 (必要に応じて調整・確認) ---
# WANDB_API_KEY は docker-compose.yml や .env で設定済みと仮定
# export WANDB_API_KEY="YOUR_ACTUAL_KEY" # もし未設定ならここで設定
export MASTER_PORT="12345"
MODEL="wavefit-3"
JOB_ID="train-$(date +%Y%m%d-%H%M%S)" # 現在時刻でジョブIDを生成
BATCH_SIZE=32       # ★ GPUメモリに合わせて調整 (RTX 4070 Ti SUPERなら32から試す)
NUM_WORKERS=4       # CPUコア数に合わせて調整
NPROC_PER_NODE=1    # GPU数 (今回は1)
DATASET_DIR_CONT="/data/LibriTTS" # ★ LibriTTSフォルダまでのパス
ROOT_DIR_CONT="/app"
OUTPUT_DIR_CONT="${ROOT_DIR_CONT}/output/${MODEL}/${JOB_ID}"

# 学習スクリプトに渡すデータセットのパスリスト
# 今回は train-clean-100 と test-clean のみ展開したと仮定
TRAIN_DIRS="[${DATASET_DIR_CONT}/train-clean-100/]"
TEST_DIRS="[${DATASET_DIR_CONT}/test-clean/]"
# もし train-clean-360 も展開していれば TRAIN_DIRS に追加:
# TRAIN_DIRS="[${DATASET_DIR_CONT}/train-clean-100/,${DATASET_DIR_CONT}/train-clean-360/]"

# 出力ディレクトリを作成 (存在しない場合)
mkdir -p ${OUTPUT_DIR_CONT}

echo "--- Starting Training ---"
echo "Model: ${MODEL}"
echo "Job ID: ${JOB_ID}"
echo "Batch Size: ${BATCH_SIZE}"
echo "Train Dirs: ${TRAIN_DIRS}"
echo "Test Dirs: ${TEST_DIRS}"
echo "Output Dir (in container): ${OUTPUT_DIR_CONT}"
echo "WandB API Key: (Set)"
echo "-------------------------"

# 学習コマンド実行
torchrun --nproc_per_node ${NPROC_PER_NODE} --master_port ${MASTER_PORT} ${ROOT_DIR_CONT}/src/train.py \
  model=${MODEL} \
  data.train.dir_list=${TRAIN_DIRS} \
  data.test.dir_list=${TEST_DIRS} \
  trainer.output_dir=${OUTPUT_DIR_CONT} \
  trainer.batch_size=${BATCH_SIZE} \
  trainer.num_workers=${NUM_WORKERS} \
  trainer.logger.project_name=${MODEL} \
  trainer.logger.run_name=job-${JOB_ID} \
  ++trainer.device_id=0 # シングルGPUの場合、明示的にGPU ID 0 を指定
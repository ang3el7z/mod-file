#!/bin/sh

# === Параметры ===
BLOCK_SIZE_MB=10     # Размер одного блока (в МБ)
BLOCK_COUNT=7        # Количество блоков (7 × 10 = 70 МБ)
SLEEP_SECONDS=1      # Пауза между блоками
TMP_DIR="/tmp/memfill"
LOG_FILE="/tmp/fill_memory.log"

# === Подготовка ===
mkdir -p "$TMP_DIR"
echo "[$(date)] Начинаем заполнение памяти (~$((BLOCK_SIZE_MB * BLOCK_COUNT)) MB)" > "$LOG_FILE"

# === Заполнение памяти ===
for i in $(seq 1 "$BLOCK_COUNT"); do
    BLOCK_FILE="$TMP_DIR/block_$i"
    dd if=/dev/zero of="$BLOCK_FILE" bs=1M count=$BLOCK_SIZE_MB status=none
    echo "[$(date)] Записан блок $i (${BLOCK_SIZE_MB}MB)" >> "$LOG_FILE"
    sleep "$SLEEP_SECONDS"
done

echo "[$(date)] Заполнение завершено" >> "$LOG_FILE"
free -m >> "$LOG_FILE"

# === Инструкция по удалению ===
echo "Чтобы освободить память, выполните: rm -rf $TMP_DIR" >> "$LOG_FILE"

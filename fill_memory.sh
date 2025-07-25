#!/bin/sh

BLOCK_SIZE_MB=10
BLOCK_COUNT=7
SLEEP_SECONDS=1
TMP_DIR="/tmp/memfill"
LOG_FILE="/tmp/fill_memory.log"

mkdir -p "$TMP_DIR"
echo "[$(date)] Начинаем заполнение памяти (~$((BLOCK_SIZE_MB * BLOCK_COUNT)) MB)" > "$LOG_FILE"

for i in $(seq 1 "$BLOCK_COUNT"); do
    BLOCK_FILE="$TMP_DIR/block_$i"
    dd if=/dev/zero of="$BLOCK_FILE" bs=1M count=$BLOCK_SIZE_MB status=none
    echo "[$(date)] Записан блок $i (${BLOCK_SIZE_MB}MB)" >> "$LOG_FILE"
    sleep "$SLEEP_SECONDS"
done

echo "[$(date)] Заполнение завершено" >> "$LOG_FILE"
free -m >> "$LOG_FILE"

echo "Лог доступен по пути: $LOG_FILE"
echo ""
echo "Если хочешь вернуть всё как было и освободить память, нажми y и Enter:"
read -r confirm
if [ "$confirm" = "y" ]; then
    rm -rf "$TMP_DIR"
    echo "[$(date)] Память освобождена (удалены временные файлы)" >> "$LOG_FILE"
    echo "Память очищена."
else
    echo "Память оставлена занятой. Удаление вручную: rm -rf $TMP_DIR"
fi

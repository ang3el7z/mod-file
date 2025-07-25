#!/bin/sh

BLOCK_SIZE_MB=10
TMP_DIR="/tmp/memfill"
LOG_FILE="/tmp/fill_memory.log"
BLOCK_INDEX=1

mkdir -p "$TMP_DIR"
echo "[$(date)] Заполнение памяти блоками по ${BLOCK_SIZE_MB}MB" > "$LOG_FILE"

while true; do
    BLOCK_FILE="$TMP_DIR/block_$BLOCK_INDEX"
    dd if=/dev/zero of="$BLOCK_FILE" bs=1M count=$BLOCK_SIZE_MB 2>/dev/null
    echo "[$(date)] Записан блок $BLOCK_INDEX (${BLOCK_SIZE_MB}MB)" >> "$LOG_FILE"

    USED_MB=$((BLOCK_INDEX * BLOCK_SIZE_MB))
    echo "Добавлено: $USED_MB MB"

    printf "Добавить ещё %dMB? (y/n): " $BLOCK_SIZE_MB
    read add_more
    case "$add_more" in
        y|Y) ;;
        *) break ;;
    esac

    BLOCK_INDEX=$((BLOCK_INDEX + 1))
done

echo "\nЗавершено. Всего: $((BLOCK_INDEX * BLOCK_SIZE_MB)) MB"
free >> "$LOG_FILE"
echo "Лог: $LOG_FILE"

printf "Очистить память? (y/n): "
read confirm
if [ "$confirm" = "y" ]; then
    rm -rf "$TMP_DIR"
    echo "Память очищена"
else
    echo "Удалите вручную: rm -rf $TMP_DIR"
fi

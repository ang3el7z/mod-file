#!/bin/sh

BLOCK_SIZE_MB=10
TMP_DIR="/tmp/memfill"
LOG_FILE="/tmp/fill_memory.log"
BLOCK_INDEX=1

mkdir -p "$TMP_DIR"
echo "[$(date)] Начинаем интерактивное заполнение памяти блоками по ${BLOCK_SIZE_MB}MB" > "$LOG_FILE"

while true; do
    BLOCK_FILE="$TMP_DIR/block_$BLOCK_INDEX"
    dd if=/dev/zero of="$BLOCK_FILE" bs=1M count=$BLOCK_SIZE_MB status=none
    echo "[$(date)] Записан блок $BLOCK_INDEX (${BLOCK_SIZE_MB}MB)" >> "$LOG_FILE"
    echo "Добавлено ${BLOCK_INDEX} × ${BLOCK_SIZE_MB}MB = $((BLOCK_INDEX * BLOCK_SIZE_MB))MB"

    echo -n "➕ Добавить ещё ${BLOCK_SIZE_MB}MB? (y/n): "
    read -r add_more
    if [ "$add_more" != "y" ]; then
        break
    fi

    BLOCK_INDEX=$((BLOCK_INDEX + 1))
done

echo ""
echo "💡 Заполнение завершено. Итог: $((BLOCK_INDEX * BLOCK_SIZE_MB))MB"
free -m >> "$LOG_FILE"
echo "Лог доступен по пути: $LOG_FILE"

echo ""
echo -n "🔁 Если хочешь вернуть всё как было и освободить память, нажми y и Enter: "
read -r confirm
if [ "$confirm" = "y" ]; then
    rm -rf "$TMP_DIR"
    echo "[$(date)] Память освобождена (удалены временные файлы)" >> "$LOG_FILE"
    echo "✅ Память очищена."
else
    echo "⚠️ Память оставлена занятой. Удаление вручную: rm -rf $TMP_DIR"
fi

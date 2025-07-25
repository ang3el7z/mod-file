#!/bin/sh

BLOCK_SIZE_MB=10
TMP_DIR="/tmp/memfill"
LOG_FILE="/tmp/fill_memory.log"
BLOCK_INDEX=1

mkdir -p "$TMP_DIR"
echo "[`date`] Начинаем интерактивное заполнение памяти блоками по ${BLOCK_SIZE_MB}MB" > "$LOG_FILE"

while true; do
    BLOCK_FILE="$TMP_DIR/block_$BLOCK_INDEX"
    dd if=/dev/zero of="$BLOCK_FILE" bs=1048576 count=$BLOCK_SIZE_MB status=none
    echo "[`date`] Записан блок $BLOCK_INDEX (${BLOCK_SIZE_MB}MB)" >> "$LOG_FILE"

    USED_MB=$(expr $BLOCK_INDEX \* $BLOCK_SIZE_MB)
    echo "Добавлено $BLOCK_INDEX × ${BLOCK_SIZE_MB}MB = ${USED_MB}MB"

    echo -n "➕ Добавить ещё ${BLOCK_SIZE_MB}MB? (y/n): "
    read add_more
    [ "$add_more" != "y" ] && break

    BLOCK_INDEX=$(expr $BLOCK_INDEX + 1)
done

echo ""
USED_MB=$(expr $BLOCK_INDEX \* $BLOCK_SIZE_MB)
echo "💡 Заполнение завершено. Итог: ${USED_MB}MB"
free -m >> "$LOG_FILE"
echo "Лог доступен по пути: $LOG_FILE"

echo ""
echo -n "🔁 Если хочешь вернуть всё как было и освободить память, нажми y и Enter: "
read confirm
if [ "$confirm]()

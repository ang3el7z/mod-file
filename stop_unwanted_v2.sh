#!/bin/bash

# Список шаблонов имен контейнеров, которые нужно остановить
UNWANTED_CONTAINERS=(
  "wireguard1"
  "wireguard"
  "naive"
  "shadowsocks"
  "proxy"
  "openconnect"
  "mtproto"
)

# Получаем все контейнеры (включая уже остановленные)
ALL_CONTAINERS=$(docker ps -a --format "{{.Names}}")

for container in $ALL_CONTAINERS; do
  for pattern in "${UNWANTED_CONTAINERS[@]}"; do
    if [[ "$container" == *"$pattern"* ]]; then
      STATUS=$(docker inspect -f '{{.State.Status}}' "$container")
      if [[ "$STATUS" == "exited" || "$STATUS" == "created" || "$STATUS" == "dead" ]]; then
        echo "ℹ️ Контейнер '$container' уже был остановлен (статус: $STATUS)."
      elif [[ "$STATUS" == "running" ]]; then
        echo "🛑 Останавливаю контейнер: $container"
        docker stop "$container" >/dev/null 2>&1
      else
        echo "⚠️ Контейнер '$container' в состоянии '$STATUS', пропускаю."
      fi
      break
    fi
  done
done

echo "✅ Ненужные контейнеры обработаны"

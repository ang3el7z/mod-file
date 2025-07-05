#!/bin/bash

# Настройка
SWAPFILE="/swapfile"
SWAPSIZE="1536M"

# Проверка, существует ли swap
if swapon --show | grep -q "$SWAPFILE"; then
  echo "Swap уже активен."
  exit 0
fi

# Создание swap-файла
fallocate -l $SWAPSIZE $SWAPFILE || dd if=/dev/zero of=$SWAPFILE bs=1M count=1536

# Установка прав
chmod 600 $SWAPFILE

# Инициализация swap
mkswap $SWAPFILE

# Активация swap
swapon $SWAPFILE

# Добавление в fstab для автоподключения
grep -qF "$SWAPFILE" /etc/fstab || echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab

# Настройка использования swap только при нехватке RAM
sysctl vm.swappiness=10
echo 'vm.swappiness=10' >> /etc/sysctl.conf

# Подтверждение
echo "Swap успешно создан и активирован:"
swapon --show
free -m

echo "Удаляю скрипт..."
rm -- "$0"

#!/bin/bash
echo "=== Установка Spotify Lyrics Widget для KDE Plasma 6 ==="

if ! command -v playerctl &> /dev/null; then
    echo "[-] Ошибка: playerctl не найден. Установи его (sudo dnf install playerctl)"
    exit 1
fi

# Создаем директории
mkdir -p ~/.config/spotify-widget
mkdir -p ~/.local/share/plasma/plasmoids/com.spotify.lyrics.widget
mkdir -p ~/.config/plasma-workspace/env
mkdir -p ~/.config/autostart

# Копируем файлы и подставляем реальный путь домашней директории в QML
cp -r package/* ~/.local/share/plasma/plasmoids/com.spotify.lyrics.widget/
sed -i "s|__HOME__|$HOME|g" ~/.local/share/plasma/plasmoids/com.spotify.lyrics.widget/contents/ui/main.qml

cp sync.py ~/.config/spotify-widget/sync.py
chmod +x ~/.config/spotify-widget/sync.py

# Настройка окружения и автозапуска
echo "export QML_XHR_ALLOW_FILE_READ=1" > ~/.config/plasma-workspace/env/qml_env.sh
chmod +x ~/.config/plasma-workspace/env/qml_env.sh

cat << EOT > ~/.config/autostart/spotify-sync.desktop
[Desktop Entry]
Type=Application
Exec=python3 $HOME/.config/spotify-widget/sync.py
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name=Spotify Widget Sync
Comment=Фоновый синхронизатор для Spotify виджета
EOT

# Запускаем фоновый скрипт прямо сейчас, чтобы не ждать перезагрузки
pkill -f sync.py
nohup python3 ~/.config/spotify-widget/sync.py >/dev/null 2>&1 &

# Перезапуск оболочки
echo "[+] Установка завершена! Перезапускаем plasmashell..."
kquitapp6 plasmashell || pkill plasmashell
nohup plasmashell >/dev/null 2>&1 &

echo "=== Готово! Виджет запущен и подхватит трек. ==="

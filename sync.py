import subprocess, json, time, os, urllib.request, urllib.parse

cache = os.path.expanduser("~/.cache/spotify_widget.json")
os.makedirs(os.path.dirname(cache), exist_ok=True)

def get_metadata():
    try:
        title = subprocess.check_output(["playerctl", "-p", "spotify", "metadata", "title"], stderr=subprocess.DEVNULL).decode().strip()
        artist = subprocess.check_output(["playerctl", "-p", "spotify", "metadata", "artist"], stderr=subprocess.DEVNULL).decode().strip()
        status = subprocess.check_output(["playerctl", "-p", "spotify", "status"], stderr=subprocess.DEVNULL).decode().strip()
        position = float(subprocess.check_output(["playerctl", "-p", "spotify", "position"], stderr=subprocess.DEVNULL).decode().strip())
        return title, artist, status, position
    except:
        return None, None, "Stopped", 0.0

def fetch_lyrics(artist, title):
    try:
        url = f"https://lrclib.net/api/get?{urllib.parse.urlencode({'artist_name': artist, 'track_name': title})}"
        req = urllib.request.Request(url, headers={'User-Agent': 'KDE-Widget'})
        with urllib.request.urlopen(req, timeout=2) as response:
            data = json.loads(response.read().decode())
            return data.get("syncedLyrics", None) or data.get("plainLyrics", None)
    except:
        return None

current_title = ""
synced_lines = []

while True:
    title, artist, status, position = get_metadata()
    
    if not title:
        data = {"title": "Spotify не запущен", "artist": "", "lyrics": "Ожидание плеера...", "status": "Stopped"}
    else:
        if title != current_title:
            current_title = title
            lyrics_raw = fetch_lyrics(artist, title)
            synced_lines = []
            if lyrics_raw and "[" in lyrics_raw:
                for line in lyrics_raw.splitlines():
                    if line.startswith("[") and "]" in line:
                        try:
                            parts = line.split("]", 1)
                            t_str = parts[0][1:]
                            m, s = map(float, t_str.split(":"))
                            synced_lines.append((m * 60 + s, parts[1].strip()))
                        except:
                            pass
            elif lyrics_raw:
                synced_lines = [(0.0, lyrics_raw)]
            else:
                synced_lines = [(0.0, "Текст не найден")]

        current_line = "♪ ♫ ♪"
        if synced_lines:
            active_text = synced_lines[0][1]
            for t, text in synced_lines:
                if position >= t:
                    active_text = text
                else:
                    break
            current_line = active_text

        data = {
            "title": title,
            "artist": artist,
            "lyrics": current_line,
            "status": status
        }

    with open(cache, "w") as f:
        json.dump(data, f)
    time.sleep(0.3)

#!/bin/sh
# Instalador de Kraken Música (Arch y derivadas, x86_64). Uso:
#   curl -fsSL https://raw.githubusercontent.com/nvrkraken/kraken-musica-releases/main/instalar.sh | sh
#   sh instalar.sh                 desde la carpeta descomprimida
#   sh instalar.sh --desinstalar   quita la app (tu música y tus playlists quedan)
# No necesita permisos de administrador salvo para instalar lo que falte del sistema (mpv, ffmpeg, yt-dlp…).
# Con AUR es más simple: yay -S kraken-musica-bin
set -eu

REPO=nvrkraken/kraken-musica-releases
BIN="$HOME/.local/bin"
DATOS="${XDG_DATA_HOME:-$HOME/.local/share}"
CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}"
AQUI=$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo .)

dicho() { printf '\033[1m» %s\033[0m\n' "$*"; }
falla() { printf '\033[31m✗ %s\033[0m\n' "$*" >&2; exit 1; }
hay() { command -v "$1" >/dev/null 2>&1; }
SUDO=sudo; [ "$(id -u)" = 0 ] && SUDO=""

archivos() {
    # íconos y acceso en el menú de aplicaciones
    mkdir -p "$DATOS/icons/hicolor/scalable/apps" "$DATOS/applications"
    cp "$1/kraken-musica.svg" "$DATOS/icons/hicolor/scalable/apps/kraken-musica.svg"
    cp "$1/kraken-musica.svg" "$DATOS/icons/kraken-musica.svg"
    cat > "$DATOS/applications/kraken-musica.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Kraken Música
Comment=Reproductor liviano en la bandeja (YouTube Music)
Exec=$BIN/kraken-musica --abrir
Icon=kraken-musica
Categories=AudioVideo;Audio;Player;
StartupNotify=false
EOF
    hay update-desktop-database && update-desktop-database -q "$DATOS/applications" 2>/dev/null || true
}

if [ "${1:-}" = "--solo-archivos" ]; then archivos "$AQUI"; exit 0; fi

if [ "${1:-}" = "--desinstalar" ]; then
    "$BIN/kraken-musica" salir 2>/dev/null || true
    rm -f "$BIN/kraken-musica" "$DATOS/applications/kraken-musica.desktop" "$CONFIG/autostart/kraken-musica.desktop" \
          "$DATOS/icons/hicolor/scalable/apps/kraken-musica.svg" "$DATOS/icons/kraken-musica.svg"
    dicho "Kraken Música desinstalada. Tus playlists e historial siguen en $DATOS/kraken-musica (bórralo si no los quieres)."
    exit 0
fi

[ "$(uname -m)" = x86_64 ] || falla "Por ahora solo hay versión para PC x86_64."

# ── sin el programa al lado (curl | sh): se baja la última versión y se sigue desde ahí ──
if [ ! -f "$AQUI/kraken-musica" ]; then
    hay curl || falla "Falta curl. Instálalo con el gestor de paquetes de tu distro y vuelve a probar."
    dicho "Buscando la última versión…"
    TMP=$(mktemp -d)
    trap 'rm -rf "$TMP"' EXIT
    URL=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | grep -o '"browser_download_url": *"[^"]*x86_64\.tar\.gz"' | head -1 | sed 's/.*"\(http[^"]*\)"/\1/')
    [ -n "$URL" ] || falla "No encontré una versión publicada en github.com/$REPO"
    ARCH=$(basename "$URL")
    curl -fL --progress-bar -o "$TMP/$ARCH" "$URL"
    curl -fsSL -o "$TMP/$ARCH.sha256" "$URL.sha256"
    (cd "$TMP" && sha256sum -c --quiet "$ARCH.sha256") || falla "La descarga llegó dañada; vuelve a intentarlo."
    tar -C "$TMP" -xzf "$TMP/$ARCH"
    sh "$TMP/${ARCH%.tar.gz}/instalar.sh" "$@"
    exit $?
fi

# ── 1. lo que se necesita del sistema (por ahora: Arch y derivadas — CachyOS, EndeavourOS, Manjaro…) ──
hay pacman || falla "Por ahora Kraken Música es solo para Arch y derivadas (CachyOS, EndeavourOS, Manjaro…)."
FALTA=""
for c in mpv ffprobe python3 yt-dlp curl notify-send pactl parec; do hay "$c" || FALTA="$FALTA $c"; done
python3 -c 'import ytmusicapi' 2>/dev/null || FALTA="$FALTA ytmusicapi"
if [ -n "$FALTA" ]; then
    dicho "Faltan cosas del sistema:$FALTA"
    CMD="pacman -S --needed mpv ffmpeg python yt-dlp python-ytmusicapi python-mutagen libnotify curl libpulse cava"
    dicho "Se instalarán con: sudo $CMD"
    dicho "(te va a pedir tu contraseña)"
    $SUDO $CMD || falla "No se pudieron instalar. Revisa el mensaje de arriba."
fi

# ── 3. la app ──
dicho "Instalando Kraken Música…"
mkdir -p "$BIN"
"$BIN/kraken-musica" salir 2>/dev/null || true
cp "$AQUI/kraken-musica" "$BIN/kraken-musica.nueva"
chmod 755 "$BIN/kraken-musica.nueva"
mv -f "$BIN/kraken-musica.nueva" "$BIN/kraken-musica"
archivos "$AQUI"

VERSION=$("$BIN/kraken-musica" --version 2>/dev/null || echo "kraken-musica")
dicho "Listo: $VERSION"
echo "  · Ábrela desde el menú de aplicaciones (Kraken Música) o con: $BIN/kraken-musica --abrir"
echo "  · Queda en la bandeja del sistema y arranca sola al iniciar sesión."
echo "  · Se actualiza sola: cuando haya versión nueva aparece una flecha arriba en el reproductor."
case ":$PATH:" in *":$BIN:"*) ;; *) echo "  · Para usarla desde la terminal, agrega $BIN a tu PATH." ;; esac
[ -n "${KRAKEN_SIN_ABRIR:-}" ] || nohup "$BIN/kraken-musica" --abrir >/dev/null 2>&1 &

# Kraken Música

Reproductor liviano estilo Walkman para YouTube Music. Vive en la bandeja del sistema, arma mixes del día con bandas
parecidas y nuevas, tiene ecualizador, playlists, descargas para escuchar sin internet y 18 visualizadores que no usan la GPU.

Este repositorio solo publica las versiones listas para instalar.

## Instalar

Por ahora funciona en **Arch y derivadas** (CachyOS, EndeavourOS, Manjaro…), en PC x86_64.

**Con AUR** (recomendado; se actualiza junto con el sistema):

```
yay -S kraken-musica-bin
```

**Con el instalador** (se actualiza sola desde el reproductor):

```
curl -fsSL https://raw.githubusercontent.com/nvrkraken/kraken-musica-releases/main/instalar.sh | sh
```

Instala lo que falte del sistema (mpv, ffmpeg, yt-dlp, ytmusicapi; te pide la contraseña solo para eso), deja la app en
`~/.local/bin`, la agrega al menú de aplicaciones y la hace arrancar con la sesión.

## Actualizar

Cuando hay una versión nueva aparece una **flecha con un punto rojo** arriba en el reproductor y una opción en el menú
de la bandeja. Al tocarla se baja, se verifica y se reinicia en la misma canción. Si la instalaste con AUR, solo avisa:
actualiza con `yay -Syu`.

## Desinstalar

```
curl -fsSL https://raw.githubusercontent.com/nvrkraken/kraken-musica-releases/main/instalar.sh | sh -s -- --desinstalar
```

(o `yay -R kraken-musica-bin`). Tus playlists e historial quedan en `~/.local/share/kraken-musica`.

## Problemas y sugerencias

Abre un *issue* en este repositorio: qué hiciste, qué pasó y la salida de `kraken-musica version`.

Las fuentes Rubik y Maple Mono incluidas usan la licencia SIL Open Font License 1.1.

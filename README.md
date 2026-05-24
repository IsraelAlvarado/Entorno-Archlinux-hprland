# ✦ hyprland-dotfiles · israel

> Arch Linux · Hyprland Lua API · Wayland-native

Configuración modular de Hyprland escrita en **Lua** con scripts de Bash para gestión de wallpapers, actualizaciones y utilidades del sistema.

---

## 📁 Estructura del proyecto

```
~/.config/hypr/
├── hyprland.lua          # Entrada principal — carga todo
├── hyprlock.conf         # Pantalla de bloqueo (glassmorphism)
│
├── config/
│   ├── general.lua       # Gaps, bordes, blur, sombras, dwindle, input
│   ├── keyboard.lua      # Layouts de teclado (us, es, …)
│   ├── animations.lua    # Curvas bezier y efectos de ventana/workspace
│   └── rules.lua         # Reglas de ventana y capa (windowrulev2, layerrule)
│
├── binds/
│   ├── apps.lua          # Lanzadores, Waydroid, sistema, utilidades
│   ├── windows.lua       # Foco, mover, redimensionar, fullscreen, dwindle
│   ├── workspaces.lua    # Workspaces 1-5, navegación, scratchpad
│   ├── screenshots.lua   # Capturas a disco y portapapeles (hyprshot)
│   ├── media.lua         # Volumen, brillo, reproducción (swayosd, playerctl)
│   └── keyboard.lua      # Cambio de layout de teclado en tiempo real
│
└── scripts/
    ├── wallpaper-cycle.sh   # Motor de wallpapers con collages automáticos (awww)
    ├── wallpaper-gui.sh     # GUI de configuración del motor (yad)
    ├── wallpaper.conf       # Parámetros del motor (intervalo, transición, FPS…)
    ├── update-manager.sh    # Centro de actualizaciones Arch/AUR (yad)
    ├── update-ui.sh         # UI completa: buscar, instalar, desinstalar paquetes
    ├── show-binds.sh        # Visor de atajos de teclado activos (hyprctl + yad)
    └── toggle-mute.sh       # Toggle mute de altavoz (swayosd)
```

---

## ⌨️ Atajos principales

### Aplicaciones
| Atajo | Acción |
|---|---|
| `SUPER + Q` | Terminal (kitty) |
| `SUPER + E` | Gestor de archivos (dolphin) |
| `SUPER + R` | Lanzador de apps (hyprlauncher) |
| `SUPER + F` | fastfetch en ventana flotante |
| `SUPER + M` | Menú de apagado (hyprshutdown) |
| `SUPER + CTRL + L` | Bloquear pantalla (hyprlock) |
| `SUPER + ALT + R` | Recargar configuración de Hyprland |

### Ventanas
| Atajo | Acción |
|---|---|
| `SUPER + C` | Cerrar ventana activa |
| `SUPER + V` | Alternar flotante |
| `SUPER + SHIFT + F` | Pantalla completa real |
| `SUPER + SHIFT + W` | Maximizar (sin ocultar waybar) |
| `SUPER + ← ↑ → ↓` | Mover foco (también HJKL) |
| `SUPER + SHIFT + flechas` | Mover ventana en tiling |
| `SUPER + = / -` | Ajustar ratio del split |
| `SUPER + ALT + M` | Submap de redimensionado (salir: ESC/Enter) |
| `SUPER + P` | Pseudo tiling (dwindle) |
| `SUPER + T` | Toggle split horizontal/vertical |

### Workspaces
| Atajo | Acción |
|---|---|
| `SUPER + 1-5` | Ir al workspace |
| `SUPER + SHIFT + 1-5` | Mover ventana al workspace |
| `SUPER + N / SHIFT+N` | Workspace siguiente / anterior |
| `SUPER + \`` | Mostrar/ocultar scratchpad |
| `SUPER + SHIFT + \`` | Enviar ventana al scratchpad |

### Capturas de pantalla
| Atajo | Acción |
|---|---|
| `Print` | Seleccionar región → guardar |
| `SHIFT + Print` | Pantalla completa → guardar |
| `SUPER + Print` | Ventana activa → guardar |
| `CTRL + Print` | Región → portapapeles |
| `CTRL + SHIFT + Print` | Pantalla completa → portapapeles |

### Media
| Atajo | Acción |
|---|---|
| `XF86AudioRaiseVolume / LowerVolume` | Volumen ±5% |
| `XF86AudioMute` | Silenciar altavoz |
| `SUPER + A` | Toggle mute altavoz |
| `SUPER + SHIFT + A` | Toggle mute micrófono |
| `SUPER + ALT + ↑/↓` | Volumen con teclado |
| `XF86MonBrightnessUp/Down` | Brillo (brightnessctl + swayosd OSD) |
| `XF86AudioPlay/Next/Prev` | Control de reproducción (playerctl) |

### Teclado
| Atajo | Acción |
|---|---|
| `SUPER + SPACE` | Siguiente layout de teclado |
| `SUPER + SHIFT + SPACE` | Layout anterior |
| `SUPER + ALT + 0` | Forzar inglés (us) |
| `SUPER + ALT + 1` | Forzar español (es) |

### Utilidades
| Atajo | Acción |
|---|---|
| `SUPER + ALT + C` | Selector de color (hyprpicker → portapapeles) |
| `SUPER + ALT + V` | Historial del portapapeles (cliphist + wofi) |
| `SUPER + ALT + D` | Limpiar historial del portapapeles |
| `CTRL + SPACE` | Cerrar notificación más reciente (swaync) |
| `CTRL + SHIFT + SPACE` | Cerrar todas las notificaciones |
| `CTRL + SHIFT + .` | Abrir/cerrar panel de notificaciones |

---

## 🖼️ Motor de wallpapers

El script `wallpaper-cycle.sh` gestiona los fondos de pantalla con soporte de **collages automáticos** generados con ImageMagick.

**Características:**
- 6 layouts de collage: `grid`, `scatter`, `cascade`, `strip_h`, `strip_v`, `fan`
- 6 formas por imagen: `circle`, `landscape`, `portrait`, `square`, `wide`, `tall`
- 6 transiciones: `fade`, `wipe`, `wave`, `grow`, `outer`, `simple`
- Rotaciones y opacidad aleatorias por imagen
- Modo aleatorio o alfabético
- Señal `USR1` para saltar al siguiente wallpaper sin esperar el intervalo

**Configuración** (`scripts/wallpaper.conf`):

```ini
INTERVAL=60           # Segundos entre cambios
TRANSITION=random     # Efecto de transición
DURATION=5            # Duración del efecto (s)
FPS=30                # Suavidad de la transición
ENABLE_COLLAGE=0      # 1 = activar collages
COLLAGE_CHANCE=55     # Probabilidad de collage (%)
COLLAGE_MIN=4         # Mínimo de fotos en el collage
COLLAGE_MAX=9         # Máximo de fotos en el collage
RANDOM_ORDER=1        # 1 = aleatorio, 0 = alfabético
SMART_TRANSITIONS=1   # 1 = no repetir transición consecutiva
```

Abrir la GUI de configuración:

```bash
~/.config/hypr/scripts/wallpaper-gui.sh
```

Directorio de wallpapers esperado: `~/Pictures/wallpapers/`

---

## 📦 Dependencias

| Paquete | Uso |
|---|---|
| `hyprland` | Compositor Wayland |
| `hyprlock` | Pantalla de bloqueo |
| `hyprshot` | Capturas de pantalla |
| `hyprpicker` | Selector de color |
| `awww` | Daemon de wallpapers (`awww-daemon`, `awww img`) |
| `waybar` | Barra de estado |
| `kitty` | Terminal |
| `dolphin` | Gestor de archivos |
| `hyprlauncher` | Lanzador de aplicaciones |
| `swayosd` | OSD para volumen y brillo |
| `swaync` | Notificaciones |
| `brightnessctl` | Control de brillo de pantalla |
| `playerctl` | Control de reproducción multimedia |
| `cliphist` | Historial del portapapeles |
| `wl-clipboard` | Portapapeles Wayland (`wl-copy`, `wl-paste`) |
| `wofi` | Menú dmenu para portapapeles |
| `nm-applet` | Bandeja de red (NetworkManager) |
| `yad` | GUI de scripts (update-manager, wallpaper-gui) |
| `imagemagick` | Generación de collages |
| `yay` | AUR helper (update-manager) |
| `pacman-contrib` | `checkupdates` para update-manager |
| `pkexec` | Autenticación para Waydroid |
| `waydroid` | Contenedor Android (opcional) |
| `JetBrainsMono Nerd Font` | Fuente usada en hyprlock y scripts |

---

## 🚀 Instalación rápida

```bash
# Clonar en la ubicación esperada
git clone <repo-url> ~/.config/hypr

# Dar permisos de ejecución a los scripts
chmod +x ~/.config/hypr/scripts/*.sh

# Instalar dependencias principales (Arch)
yay -S hyprland hyprlock hyprshot hyprpicker awww waybar kitty \
        dolphin swayosd swaync brightnessctl playerctl cliphist \
        wl-clipboard wofi yad imagemagick pacman-contrib \
        ttf-jetbrains-mono-nerd

# Iniciar Hyprland
Hyprland
```

---

## 🎨 Hyprlock

La pantalla de bloqueo usa un tema **glassmorphism** con:
- Fondo con wallpaper fijo configurable
- Reloj grande con sombra
- Fecha dinámica localizada
- Avatar circular con borde de acento
- Campo de contraseña con blur y animaciones
- Botones de apagado, reinicio y cierre de sesión en la parte inferior

Para cambiar el wallpaper del lock screen, edita `hyprlock.conf`:

```
background {
    path = ~/Pictures/wallpapers/tu-imagen.png
}
```

---

## 🔧 Personalización rápida

**Agregar un layout de teclado** — editar `config/keyboard.lua`:
```lua
local LAYOUTS  = "us,es,fr"
local VARIANTS = ",,"
```

**Cambiar terminal o lanzador** — editar `binds/apps.lua`:
```lua
local terminal    = "alacritty"
local fileManager = "thunar"
local menu        = "rofi -show drun"
```

**Ajustar gaps y rounding** — editar `config/general.lua`:
```lua
general = { gaps_in = 5, gaps_out = 10, border_size = 2 },
decoration = { rounding = 10 },
```

**Ver todos los atajos activos:**
```bash
~/.config/hypr/scripts/show-binds.sh
```

---

## 📝 Notas

- El proyecto usa la **API Lua de Hyprland**. No es compatible con el formato `.conf` tradicional.
- Las variables de entorno NVIDIA en `hyprland.lua` son necesarias para GPUs NVIDIA con el driver propietario. Si usas AMD o Intel, puedes eliminar ese bloque.
- El `SUPER + L` para bloqueo está comentado en `binds/windows.lua` por colisión con el atajo vim `L` de foco — elige uno según tu preferencia.
- `wl-paste --watch cliphist store` se inicia en el autostart; es necesario para que el historial del portapapeles funcione.

<img width="2550" height="1491" alt="image" src="https://github.com/user-attachments/assets/57214c93-5060-4658-8300-5ceb550488e4" />
<img width="2528" height="1568" alt="image" src="https://github.com/user-attachments/assets/290f2e70-c440-4912-8e75-06e5735b5fd8" />
<img width="2518" height="1504" alt="image" src="https://github.com/user-attachments/assets/327a5ebb-b456-4688-b0e7-72dfafc8c893" />


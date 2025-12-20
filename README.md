# Hyprland Dotfiles Setup Guide

Based on [saatvik333/hyprland-dotfiles](https://github.com/saatvik333/hyprland-dotfiles), with fixes and adjustments for Hyprland 0.52+.

## Package Installation

### One-liner (Arch/AUR)

```bash
yay -S --needed \
  hyprland hyprlock hypridle xdg-desktop-portal-hyprland hyprpolkitagent \
  waybar swaync dunst \
  swww wallust waytrogen \
  wofi wlogout \
  alacritty kitty \
  pipewire wireplumber pipewire-pulse pavucontrol \
  bluez bluez-utils \
  brightnessctl playerctl imagemagick bc jq \
  thunar udiskie \
  grim slurp wl-clipboard \
  hyprswitch hyprpicker \
  ttf-material-symbols-variable noto-fonts-cjk nerd-fonts-sf-mono-ligatures \
  colloid-gtk-theme-git \
  starship eza dust bottom \
  gnome-keyring libsecret
```

### Detailed Package List

#### Core Hyprland Stack
| Package | Purpose | Required |
|---------|---------|----------|
| `hyprland` | Wayland compositor | Yes |
| `hyprlock` | Lock screen | Yes |
| `hypridle` | Idle daemon (screen timeout, suspend) | Yes |
| `xdg-desktop-portal-hyprland` | Desktop integration (file dialogs, screen sharing) | Yes |
| `hyprpolkitagent` | Polkit authentication agent | Yes |

#### Status Bar & Notifications
| Package | Purpose | Required |
|---------|---------|----------|
| `waybar` | Status bar | Yes |
| `swaync` | Notification center | Yes |
| `dunst` | Notification daemon (fallback) | Optional |

#### Wallpaper & Theming
| Package | Purpose | Required |
|---------|---------|----------|
| `swww` | Wallpaper daemon with transitions | Yes |
| `wallust` | Color extraction from wallpapers | Yes |
| `waytrogen` | GUI wallpaper picker | Yes |
| `colloid-gtk-theme-git` | GTK theme (AUR) | Yes |

#### Launchers & Menus
| Package | Purpose | Required |
|---------|---------|----------|
| `wofi` | Application launcher | Yes |
| `wlogout` | Logout/power menu | Yes |

#### Terminals
| Package | Purpose | Required |
|---------|---------|----------|
| `alacritty` | Primary terminal (default $terminal) | Yes |
| `kitty` | Alternative terminal | Optional |

#### Audio
| Package | Purpose | Required |
|---------|---------|----------|
| `pipewire` | Audio server | Yes |
| `wireplumber` | PipeWire session manager | Yes |
| `pipewire-pulse` | PulseAudio compatibility | Yes |
| `pavucontrol` | Volume control GUI | Yes |
| `easyeffects` | Audio effects (referenced in autostart) | Optional |
| `mpd` | Music Player Daemon | Optional |
| `mpd-mpris` | MPRIS bridge for MPD (waybar integration) | Optional |
| `ncmpcpp` | Terminal MPD client | Optional |
| `cliphist` | Clipboard history manager | Optional |
| `hyprsunset` | Night mode / color temperature | Optional |
| `wtype` | Keyboard input simulation (for cliphist auto-paste) | Optional |

#### Bluetooth
| Package | Purpose | Required |
|---------|---------|----------|
| `bluez` | Bluetooth stack | Yes* |
| `bluez-utils` | Bluetooth utilities | Yes* |
| `blueman` | Bluetooth manager GUI | Optional |

*Required if using waybar bluetooth module (otherwise it crashes)

#### Brightness & Media
| Package | Purpose | Required |
|---------|---------|----------|
| `brightnessctl` | Backlight control | Yes |
| `playerctl` | Media player control | Yes |

#### Screenshot & Clipboard
| Package | Purpose | Required |
|---------|---------|----------|
| `grim` | Screenshot tool | Yes |
| `slurp` | Region selection | Yes |
| `wl-clipboard` | Wayland clipboard (wl-copy, wl-paste) | Yes |

#### Utilities
| Package | Purpose | Required |
|---------|---------|----------|
| `imagemagick` | Image processing (magick command) | Yes |
| `bc` | Calculator for scripts | Yes |
| `jq` | JSON processor | Yes |
| `hyprswitch` | Window/workspace switcher | Yes |
| `hyprpicker` | Color picker | Optional |

#### File Management
| Package | Purpose | Required |
|---------|---------|----------|
| `thunar` | File manager (default $fileManager) | Yes |
| `udiskie` | Automount removable media | Optional |

#### Fonts
| Package | Purpose | Required |
|---------|---------|----------|
| `ttf-material-symbols-variable` | Waybar icons | Yes |
| `noto-fonts-cjk` | Japanese workspace characters | Yes |
| `nerd-fonts-sf-mono-ligatures` | Terminal font (Liga SFMono) | Yes |
| `otf-san-francisco` or manual install | UI font (SF Pro Display) | Yes |

#### Shell Enhancements (from shell.env)
| Package | Purpose | Required |
|---------|---------|----------|
| `starship` | Shell prompt | Optional |
| `eza` | Modern ls replacement | Optional |
| `dust` | Modern du replacement | Optional |
| `bottom` | System monitor (btm) | Optional |
| `fastfetch` / `neofetch` | System info | Optional |

#### Authentication
| Package | Purpose | Required |
|---------|---------|----------|
| `gnome-keyring` | Secret storage | Optional |
| `libsecret` | Secret service library | Optional |

#### Browser (configure in variables.conf)
| Package | Purpose | Required |
|---------|---------|----------|
| `zen-browser` | Default browser (AUR) | No* |
| `firefox` | Alternative browser | No* |

*Change `$browser` in `~/.config/hypr/config/variables.conf`

## Directory Structure

```
~/.config/
├── hypr/
│   ├── hyprland.conf           # Main config (sources others)
│   ├── config/
│   │   ├── variables.conf      # $terminal, $browser, etc.
│   │   ├── appearance.conf     # Gaps, borders, blur, opacity
│   │   ├── animations.conf
│   │   ├── input.conf          # Keyboard, touchpad, gestures
│   │   ├── autostart.conf      # exec-once commands
│   │   ├── border.conf         # Generated by wallust
│   │   └── ...
│   ├── keybinds/
│   │   ├── applications.conf
│   │   ├── windows.conf
│   │   ├── workspaces.conf
│   │   └── media.conf
│   ├── rules/
│   ├── hyprlock.conf
│   └── hypridle.conf
├── waybar/
│   ├── config.jsonc
│   ├── style.css
│   └── colors.css              # Generated by wallust
├── wallust/
│   ├── wallust.toml            # Template configuration
│   └── templates/              # Color templates for all apps
├── scripts/
│   ├── theme/
│   │   ├── theme-sync.sh       # Master theme orchestrator
│   │   ├── wallpaper-rotate.sh # Auto wallpaper rotation
│   │   ├── waybar-detection.sh # Light/dark detection
│   │   ├── gtk-colors.sh       # GTK theme switching
│   │   └── wofi-colors.sh
│   ├── media/
│   │   └── volume-brightness.sh
│   ├── system/
│   │   ├── package-updates.sh
│   │   └── battery-notify.sh
│   ├── utils/
│   │   ├── screenshot.sh
│   │   └── util-launcher.sh    # Emoji picker, etc.
│   └── lib/
│       ├── common.sh
│       └── color-utils.sh
├── gtk-3.0/
│   ├── gtk.css                 # Imports colors.css
│   └── colors.css              # Generated by wallust
├── gtk-4.0/
│   ├── gtk.css -> /usr/share/themes/Colloid-Dark/gtk-4.0/gtk.css
│   └── colors.css              # Generated by wallust
├── waytrogen/
│   └── config.json             # Set wallpaper_folder here
├── wofi/
├── swaync/
├── alacritty/
│   └── colors.toml             # Generated by wallust
├── kitty/
│   └── colors.conf             # Generated by wallust
├── wlogout/
├── starship/
│   └── starship.toml
└── shell.env                   # Aliases and environment

~/Pictures/
└── Wallpapers/
    ├── Black/          # Maps to Colloid-Dark theme
    ├── Catppuccin/     # Maps to Colloid-Dark-Catppuccin
    ├── Gruvbox/        # Maps to Colloid-Dark-Gruvbox
    ├── Nord/           # Maps to Colloid-Dark-Nord
    └── Everforest/     # Maps to Colloid-Dark-Everforest

~/.config/systemd/user/
├── wallpaper-rotate.service
└── wallpaper-rotate.timer      # 15-minute rotation
```

## Post-Install Configuration

### 1. Enable system services

```bash
# Bluetooth
sudo systemctl enable --now bluetooth

# Audio (user services)
systemctl --user enable --now pipewire pipewire-pulse wireplumber
```

### 2. Enable MPD (Music Player Daemon)

MPD provides music playback, and mpd-mpris bridges it to MPRIS so waybar's media controls work.

```bash
# Enable both services to start on login
systemctl --user enable --now mpd.service
systemctl --user enable --now mpd-mpris.service
```

**Important configuration notes:**

1. **Remove from Hyprland autostart** - Do NOT use `exec-once = mpd` or `exec-once = mpd-mpris` in `~/.config/hypr/config/autostart.conf`. The systemd services handle startup.

2. **Disable duplicate audio output** - MPD's default config enables both PipeWire and PulseAudio outputs, causing double audio. In `~/.config/mpd/mpd.conf`, disable the PulseAudio fallback:
   ```conf
   audio_output {
       type    "pulse"
       name    "PulseAudio"
       enabled "no"
   }
   ```

3. **Bind mpd-mpris to mpd** - Create an override so mpd-mpris restarts when mpd restarts:
   ```bash
   mkdir -p ~/.config/systemd/user/mpd-mpris.service.d
   cat > ~/.config/systemd/user/mpd-mpris.service.d/restart-with-mpd.conf << 'EOF'
   [Unit]
   BindsTo=mpd.service
   After=mpd.service
   EOF
   systemctl --user daemon-reload
   ```

4. **Required packages:**
   ```bash
   yay -S mpd mpd-mpris ncmpcpp mpc
   ```
   - `mpd` - Music Player Daemon
   - `mpd-mpris` - MPRIS bridge for waybar integration
   - `ncmpcpp` - Terminal UI for MPD (optional)
   - `mpc` - Command-line MPD client (optional)

### 3. Enable wallpaper rotation timer

```bash
systemctl --user enable --now wallpaper-rotate.timer
```

### 4. Set up clipboard history (cliphist)

Cliphist stores clipboard history and lets you recall previous copies.

1. **Install:**
   ```bash
   yay -S cliphist wl-clipboard wtype
   ```

2. **Autostart is configured** in `~/.config/hypr/config/autostart.conf`:
   ```conf
   exec-once = wl-paste --type text --watch cliphist store
   exec-once = wl-paste --type image --watch cliphist store
   ```

3. **Keybind:** `SUPER+V` opens the clipboard picker and auto-pastes
   - Terminals (Alacritty, kitty, etc.): uses `Ctrl+Shift+V`
   - Other apps: uses `Ctrl+V`
   - Script: `~/.config/scripts/utils/cliphist-paste.sh`

### 5. Set up night mode (hyprsunset)

Hyprsunset adjusts color temperature for reduced eye strain at night.

1. **Install:**
   ```bash
   yay -S hyprsunset
   ```

2. **Manual toggle:** `SUPER+F5` toggles night mode on/off (4500K warm)

3. **Automatic scheduling** via systemd timers:
   ```bash
   systemctl --user enable --now hyprsunset-on.timer   # 7 PM
   systemctl --user enable --now hyprsunset-off.timer  # 7 AM
   ```

4. **Adjust times** by editing:
   - `~/.config/systemd/user/hyprsunset-on.timer` (sunset time)
   - `~/.config/systemd/user/hyprsunset-off.timer` (sunrise time)

5. **Adjust temperature** by editing:
   - `~/.config/scripts/utils/hyprsunset-toggle.sh` (for manual toggle)
   - `~/.config/systemd/user/hyprsunset-on.service` (for auto)

### 6. Configure waytrogen

Edit `~/.config/waytrogen/config.json`:
```json
{
  "wallpaper_folder": "/home/YOUR_USER/Pictures/Wallpapers"
}
```

### 7. Shell setup

Add to `~/.bashrc`:
```bash
[[ -f ~/.config/shell.env ]] && source ~/.config/shell.env
eval "$(starship init bash)"
```

Or `~/.config/fish/config.fish`:
```fish
source ~/.config/shell.env
starship init fish | source
```

### 8. Customize default applications

Edit `~/.config/hypr/config/variables.conf`:
```conf
$terminal = alacritty      # or kitty
$fileManager = thunar      # or dolphin, nautilus
$browser = firefox         # or zen-browser, chromium
```

## Known Issues & Fixes Applied

### Hyprland 0.52+ gesture syntax
The old `gestures:workspace_swipe` is deprecated. Use:
```conf
gestures {
    workspace_swipe_invert = false
    workspace_swipe_distance = 300
    gesture = 3, horizontal, workspace
}
```

### Waybar font-family
CSS must use exact font name. Use `"SF Pro Display"` not `"SF Pro"`.

### Package updates script
Uses `yay -Qu` instead of `checkupdates-with-aur`.

### Theme sync script order
Fixed: colors must be generated by wallust BEFORE gsettings triggers GTK reload.

### Hyprland plugins
`hyprpm reload` is commented out by default (no plugins installed).

### Waybar bluetooth module
Requires `bluez` package (not just `bluez-utils`) or waybar will segfault.

## How Theming Works

```
┌─────────────────────────────────────────────────────────────────┐
│                    Wallpaper Change Flow                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  1. swww img [wallpaper] --transition-type fade                │
│     └── 2-second smooth wallpaper fade                         │
│                                                                 │
│  2. theme-sync.sh runs after fade completes                    │
│     ├── waybar-detection.sh                                    │
│     │   └── Analyzes top 5% of image luminosity                │
│     │   └── Swaps light/dark rgba backgrounds in template      │
│     │                                                          │
│     ├── wallust run [wallpaper]                                │
│     │   └── Extracts 16-color palette                          │
│     │   └── Generates from templates:                          │
│     │       ├── waybar/colors.css                              │
│     │       ├── gtk-3.0/colors.css                             │
│     │       ├── gtk-4.0/colors.css                             │
│     │       ├── hypr/config/border.conf                        │
│     │       ├── alacritty/colors.toml                          │
│     │       ├── kitty/colors.conf                              │
│     │       ├── wofi/colors.css                                │
│     │       ├── wlogout/colors.css                             │
│     │       └── swaync/colors.css                              │
│     │                                                          │
│     ├── wofi-colors.sh                                         │
│     │   └── Generates wofi/style.css from colors               │
│     │                                                          │
│     ├── gtk-colors.sh                                          │
│     │   └── Maps wallpaper folder → Colloid theme variant      │
│     │   └── gsettings triggers GTK app reload                  │
│     │                                                          │
│     └── reload_system_components                               │
│         ├── hyprctl reload (border colors)                     │
│         ├── swaync-client -rs                                  │
│         └── hyprswitch restart                                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Transition Smoothness

| Component | Transition | Notes |
|-----------|------------|-------|
| Wallpaper | 2s fade | swww handles this |
| Waybar | 1.5s CSS ease | Added `transition` to style.css |
| GTK apps | Instant | GTK CSS doesn't support transitions |
| Hyprland borders | Instant | No transition support |
| Window blur | Smooth | Follows wallpaper fade |

## Testing

```bash
# Manual theme sync
~/.config/scripts/theme/theme-sync.sh

# Manual wallpaper rotation
~/.config/scripts/theme/wallpaper-rotate.sh

# Check Hyprland config errors
hyprctl configerrors

# Check waybar status
pgrep waybar && echo "Running" || echo "Not running"

# Test wallust color extraction
wallust run ~/Pictures/Wallpapers/Black/example.jpg --dry-run
```

## Troubleshooting

### Waybar crashes immediately
- Install `bluez` (not just `bluez-utils`)
- Check `coredumpctl list` for crash info

### Missing icons in waybar
- Install `ttf-material-symbols-variable`
- Check font with: `fc-list | grep -i material`

### Japanese characters show as boxes
- Install `noto-fonts-cjk`
- Run `fc-cache -fv`

### Theme colors don't update
- Ensure wallpaper is in a subfolder of `~/Pictures/Wallpapers/`
- Check wallust templates exist: `ls ~/.config/wallust/templates/`
- Run theme-sync manually and check for errors

### Gestures not working
- Hyprland 0.52+ uses new syntax (see Known Issues above)
- Check `hyprctl configerrors`

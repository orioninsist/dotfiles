# System Controls

> Generated automatically from `/home/murat/.config/sway/system-controls.conf`.

| Shortcut | Action |
|---|---|
| `XF86AudioMute` | Audio, media, brightness, power and hardware toggles. |
| `XF86AudioLowerVolume` | exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- |
| `XF86AudioRaiseVolume` | exec wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+ |
| `XF86AudioPlay` | exec playerctl play-pause |
| `XF86AudioPause` | exec playerctl play-pause |
| `XF86AudioPrev` | exec playerctl previous |
| `XF86AudioNext` | exec playerctl next |
| `XF86AudioStop` | exec playerctl stop |
| `XF86MonBrightnessDown` | exec brightnessctl set 5%- |
| `XF86MonBrightnessUp` | exec brightnessctl set 5%+ |
| `Super + F1` | exec busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s performance && notify-send "Power Profile" "Performance mode enabled" |
| `Super + F2` | exec busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s balanced && notify-send "Power Profile" "Balanced mode enabled" |
| `Super + F3` | exec busctl set-property net.hadess.PowerProfiles /net/hadess/PowerProfiles net.hadess.PowerProfiles ActiveProfile s power-saver && notify-send "Power Profile" "Battery saving mode enabled" |
| `Super + t` | exec ~/.config/sway/scripts/bluetooth/bluetooth-toggle |
| `Super + F4` | exec ~/.config/sway/scripts/audio/audio-toggle |
| `Super + F5` | exec ~/.config/sway/scripts/input/mic-toggle |
| `Super + F6` | exec ~/.config/sway/scripts/input/camera-toggle |

## Source

```text
/home/murat/.config/sway/system-controls.conf
```

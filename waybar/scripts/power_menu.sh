options="⏻ Shutdown\n Reboot\n Lock"
chosen=$(echo -e "$options" | rofi -dmenu --prompt "Power Menu" -i)

case "$chosen" in
    *Shutdown*) systemctl poweroff ;;
    *Reboot*) systemctl reboot ;;
    *Lock*) loginctl lock-session ;;
esac
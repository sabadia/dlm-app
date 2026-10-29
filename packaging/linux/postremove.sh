#!/bin/sh
# After the package is removed (not upgraded), take the browser registrations of
# the extension host out of the home directories: the launcher they point to
# lived in /opt/dlm or in the user's DLM data, and is gone or about to be.
# deb passes "remove" or "purge" (and "upgrade" on upgrades); rpm passes the
# number of copies left, so 0 means a real removal.
case "$1" in
  remove | purge | 0) ;;
  *) exit 0 ;;
esac

host=dev.sabadia.dlm.json
for home in /root /home/*; do
  [ -d "$home" ] || continue
  for dir in \
    ".config/google-chrome/NativeMessagingHosts" \
    ".config/chromium/NativeMessagingHosts" \
    ".config/microsoft-edge/NativeMessagingHosts" \
    ".config/BraveSoftware/Brave-Browser/NativeMessagingHosts" \
    ".mozilla/native-messaging-hosts"; do
    file="$home/$dir/$host"
    # Only the file DLM wrote: it names the host inside.
    if [ -f "$file" ] && grep -q '"dev.sabadia.dlm"' "$file" 2>/dev/null; then
      rm -f "$file"
    fi
  done
done
exit 0

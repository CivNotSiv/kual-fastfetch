#!/bin/sh

# Get the directory this script is in
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# binary locations
FBINK="$SCRIPT_DIR/fbink"
FIGLETBIN="$SCRIPT_DIR/figlet"
FIGLETFONTS="$SCRIPT_DIR/fonts"
FASTFETCH="$SCRIPT_DIR/fastfetch"

# Ascii locations
ARTFILE="$SCRIPT_DIR/ascii_art.txt"
ASCIITXTTMP="$SCRIPT_DIR/tmp/ascii_text.txt"
TMPFILE="$SCRIPT_DIR/tmp/fastfetch_output.txt"
CLEANFILE="$SCRIPT_DIR/tmp/fastfetch_clean.txt"

# Run fastfetch, save raw output
"$FASTFETCH" > "$TMPFILE"

# fastfetch cleaner
awk '
  function clean_esc_codes(line,   ESC, i, out, c, state) {
    ESC = sprintf("%c", 27)
    out = ""
    state = 0
    for (i=1; i<=length(line); i++) {
      c = substr(line,i,1)
      if (state == 0) {
        if (c == ESC) state = 1
        else out = out c
      } else if (state == 1) {
        if (c == "[") state = 2
        else { out = out ESC c; state=0 }
      } else if (state == 2) {
        if (c ~ /[0-9;?]/) {
        } else if (c ~ /[A-Za-z]/) {
          state = 0
        } else {
          state = 0
          out = out c
        }
      }
    }
    return out
  }
  {
    cleaned = clean_esc_codes($0)
    sub(/^[ #*=.\-]+/, "", cleaned)
    if (cleaned ~ /([[:alnum:]].*){3,}/)
      print cleaned
  }
' "$TMPFILE" > "$CLEANFILE"

# text gen
KERNEL_LINE=$(sed -n '2p' "$CLEANFILE" | cut -c15-)
echo "$KERNEL_LINE" | "$FIGLETBIN" -f "$FIGLETFONTS/standard.flf" > "$ASCIITXTTMP"

# print

# makes sure it sleeps for the shortest time, if gnu fails fallback to int
if sleep 1.5 2>/dev/null; then
  sleep 1.5
else
  sleep 2
fi


"$FBINK" -c -f
"$FBINK" -r -y 23 -x 17 --size 1 < "$ARTFILE"
"$FBINK" -r -y 45 -x 9 --size 1 < "$ASCIITXTTMP"
"$FBINK" -r -y 55 -x 5 --size 1 --font IBM < "$CLEANFILE"

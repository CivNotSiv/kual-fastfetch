#!/bin/sh

# binary locations
FBINK="/mnt/us/extensions/fastfetch/bin/fbink"
FIGLETBIN="/mnt/us/extensions/fastfetch/bin/figlet"
FIGLETFONTS="/mnt/us/extensions/fastfetch/bin/fonts"
FASTFETCH="/mnt/us/extensions/fastfetch/bin/fastfetch"

# Ascii locations
ARTFILE="/mnt/us/extensions/fastfetch/ascii_art.txt"
ASCIITXTTMP="/mnt/us/extensions/fastfetch/tmp/ascii_text.txt"
TMPFILE="/mnt/us/extensions/fastfetch/tmp/fastfetch_output.txt"
CLEANFILE="/mnt/us/extensions/fastfetch/tmp/fastfetch_clean.txt"



# Run fastfetch, save raw output
$FASTFETCH > "$TMPFILE"

# fastfetch cleaner
awk '
  # Function to remove escape sequences of form ESC [ params letter
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
        # skip digits, semicolon, question mark
        if (c ~ /[0-9;?]/) {
          # still in ESC sequence
        } else if (c ~ /[A-Za-z]/) {
          # end of ESC sequence, reset
          state = 0
        } else {
          # unexpected char, flush ESC sequence
          state = 0
          out = out c
        }
      }
    }
    return out
  }
  {
    cleaned = clean_esc_codes($0)
    # strip leading junk characters like space, #, *, =, ., -
    sub(/^[ #*=.\-]+/, "", cleaned)
    # print lines with at least 3 alnum chars
    if (cleaned ~ /([[:alnum:]].*){3,}/)
      print cleaned
  }
' "$TMPFILE" > "$CLEANFILE"

# text gen
KERNEL_LINE=$(sed -n '2p' "$CLEANFILE" | cut -c15-)
echo "$KERNEL_LINE" | "$FIGLETBIN" -f "$FIGLETFONTS/standard.flf" > "$ASCIITXTTMP"

# print

sleep 1.5

$FBINK -c -f

$FBINK -r -y 23 -x 17 --size 1 < "$ARTFILE"

$FBINK -r -y 45 -x 9 --size 1 < "$ASCIITXTTMP"

$FBINK -r -y 55 -x 5 --size 1 --font IBM< "$CLEANFILE"


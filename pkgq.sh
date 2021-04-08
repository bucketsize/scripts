pacman -Ss deja | grep inst | awk 'NR%2 {while(pacman -Si  | getline line) if (line ~ /Ins/) {split(line,a,/:/);printf a[2]  --  }; print   }'

#!/bin/sh
#
# Description: A dmenu wrapper around tfw.
#
# Dependencies: tfw (obviously) - https://github.com/climech/tfw
#               dmenu or rofi
#
# Shell: POSIX compliant
# Author: NRK

general_choices(){
  CHOSEN=$( printf "new\ncat\nedit\ngrep\nhelp\ninit\nlist\nremove\nversion\nview" | dmenu )
}

entry_list(){
  tfw list | dmenu -l 7
}

entry_get_id(){
  awk -F '.' '{print $1}'
}

entry_view(){
  entry_get_id | xargs -r tfw ${PAGER}
}

entry_edit(){
  entry_get_id | xargs -r tfw edit
}

entry_grep(){
  entry_get_id | xargs -r tfw grep
}

entry_remove(){
  local ID=$(entry_get_id)
  [ -z "$ID" ] && echo "No seletion, exiting..." && exit

  local CONFIRM
  which trash-put 1>/dev/null 2>&1 &&
    CONFIRM="Yes" ||
    CONFIRM=$( echo "No\nYes" | dmenu -i -p "Permanently delete entry?" )

  [ "$CONFIRM" = "Yes" ] && tfw rm "$ID"
}

[ -z "$1" ] &&
  general_choices ||
  CHOSEN="$1"

case "$CHOSEN" in
    "new" )
      tfw new
      ;;
    "list"|"view")
      PAGER="view"
      entry_list | entry_view
      ;;
    "cat")
      PAGER="cat"
      entry_list | entry_view
      ;;
    "edit")
      entry_list | entry_edit
      ;;
    "grep")
      entry_list | entry_grep
      ;;
    "help")
      tfw help
      ;;
    "remove"|"rm")
      entry_list | entry_remove
      ;;
esac

#!/bin/sh
#
# Description: A dmenu wrapper around tfw.
#
# Dependencies: tfw (obviously) - https://github.com/climech/tfw
#               dmenu or rofi
#
# Shell: POSIX compliant (i think)
# Author: NRK

#################################################################
# Change "dmenu" to "rofi -dmenu" if you wish to use rofi       #
# NOTE i do not use rofi, and haven't tested if it works or not #
#################################################################
PROMPT="dmenu"

general_choices(){
  CHOSEN=$( printf "new\ncat\nedit\ngrep\nhelp\ninit\nlist/ls\nremove/rm\nversion\nview" | "$PROMPT" )

  case "$CHOSEN" in
    "list/ls") CHOSEN=$(echo $CHOSEN | sed 's|list/ls|list|g') ;;
    "remove/rm") CHOSEN=$(echo $CHOSEN | sed 's|remove/rm|remove|g') ;;
  esac
}

entry_list(){
  tfw list | "$PROMPT" -l 7
}

entry_get_id(){
  awk -F '.' '{print $1}'
}

entry_view(){
  entry_get_id | xargs -r tfw "$PAGER"
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
    CONFIRM=$( echo "No\nYes" | "$PROMPT" -i -p "Permanently delete entry?" )

  [ "$CONFIRM" = "Yes" ] && tfw rm "$ID"
}

[ -z "$1" ] &&
  general_choices ||
  CHOSEN="$1"

case "$CHOSEN" in
    "new")
      tfw new
      ;;
    "list"|"ls"|"view")
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

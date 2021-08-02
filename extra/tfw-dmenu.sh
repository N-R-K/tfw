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

# Reverse the list so the most recent entry is at the top
REVERSE="yes"

dmenu_choices() {
  CHOSEN=$( printf "new\ncat\nedit\ngrep\nhelp\ninit\nlist/ls\nremove/rm\nversion\nview" | "${PROMPT}" )

  case "$CHOSEN" in
    "list/ls") CHOSEN="list" ;;
    "remove/rm") CHOSEN="remove" ;;
  esac
}

entry_get_id() {
  awk -F '.' '{print $1}'
}

entry_list() {
  [ "$REVERSE" = "yes" ] &&
    rev="-r"
  tfw list | sort -n ${rev} | "${PROMPT}" -l 7
}

entry_view() {
  entry_get_id | xargs -r tfw "$PAGER"
}

entry_edit() {
  entry_get_id | xargs -r tfw edit
}

entry_grep() {
  echo "" | "${PROMPT}" -p "grep:" | xargs -r tfw grep
}

entry_remove() {
  ID=$(entry_get_id)
  [ -z "$ID" ] && echo "No seletion, exiting..." && exit

  # don't as for confirmation if trash-cli exists
  which trash-put 1>/dev/null 2>&1 &&
    CONFIRM="Yes" ||
    CONFIRM=$( printf "No\nYes" | "${PROMPT}" -i -p "Permanently delete entry?" )

  [ "$CONFIRM" = "Yes" ] && tfw rm "$ID"
}

[ -z "$1" ] &&
  dmenu_choices ||
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
      entry_grep
      ;;
    "help")
      tfw help
      ;;
    "remove"|"rm")
      entry_list | entry_remove
      ;;
    *)
      echo "Invalid command" |
        "${PROMPT}" 1>/dev/null 2>&1
      ;;
esac

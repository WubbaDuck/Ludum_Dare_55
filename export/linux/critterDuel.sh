#!/bin/sh
echo -ne '\033c\033]0;Ludum Dare 55\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/critterDuel.x86_64" "$@"

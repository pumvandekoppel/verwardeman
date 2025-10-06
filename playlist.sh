#!/bin/bash

print_help() {
    echo
    echo "How to use playlist.sh:"
    echo
    echo "./playlist.sh \"path/to/audio/and/output\" \"Playlist and page title\" \"<theme>\""
    echo
    echo "<theme> - Choose a filename from the list of HTML files in the \`themes\` directory. e.g. \"default.html\". It uses \`default.html\` if none is provided."
    echo
}

if [[ "$1" == '-h' ]] || [[ "$1" == '--help' ]]; then
    print_help
    exit 0
fi

source_folder="$1"
title="$2"
theme="${3:-default.html}"

errors=

if [[ -z "$source_folder" ]]; then
    errors="Provide a folder."
fi
if [[ -z "$title" ]]; then
    if [[ -n "$errors" ]]; then
        errors="$errors"$'\n'
    fi
    errors="${errors}Provide a title."
fi

if [[ -n "$errors" ]]; then
    echo "$errors"
    echo
    print_help
    exit 1
fi

# Make temp files
link_items="$(mktemp)"
touch "$link_items"
files="$(mktemp)"

# for each mp3 in source folder
find "$source_folder" -name '*.mp3' | sort | while read -r file; do
    # Get name without source folder
    filepath="${file##*"$source_folder"/}"
    # Get name without number or extension
    small_file="${filepath%%.mp3*}"
    small_file="${small_file#* - }"
    echo "$filepath" >> "$files"
    # create HTML for link and put in playlist file
    link_html='<li><a class="track" href="'"$filepath"'">'"$small_file"'</a>'
    echo "$link_html" >> "$link_items"
done

# Get first file to prime audio player
first_file="$(head -n1 "$files" | tr "\n" ' ')"

# replace %%PLAYLIST%% with link items and replace %%FIRSTFILE%% with first_file and output to playlist file
script="$(cat <<EOF
/%%PLAYLIST%%/ {
    system("cat '$link_items'");
    next;
}

/%%FIRSTFILE%%/ {
    sub(/%%FIRSTFILE%%/,"$first_file");
}

/%%TITLE%%/ {
    sub(/%%TITLE%%/,"$title");
}

1
EOF
)"
awk "$script" "themes/$theme" > "$source_folder/index.html"

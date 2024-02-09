#!/bin/sh

# Use when using protected assets
CMD="$1"

if [ "$CMD" == "unpack" ]; then
    cd godot/assets
    unzip -d protected protected.zip
elif [ "$CMD" == "pack" ]; then
    cd godot/assets/protected
    zip -e -r ../protected.zip *
else
    echo "Unknown command. Available commands: unpack, pack"
fi

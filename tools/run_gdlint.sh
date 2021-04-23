#!/usr/bin/bash

# Runs gdlint on all files with the .gd extension
# Run this from the root of the project directory

# Relies on the gdlint executable being available in the path
find . -name *.gd | xargs -I {} bash -c "gdlint {}"
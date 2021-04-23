#!/usr/bin/bash

# Starts a dedicated server instance and a client instance
# Run this from the root of the project directory

# Relies on the godot executable being available in the path

godot --server &
godot &
#!/bin/sh
# Launcher wrapper for Pale Moon.
exec /usr/lib/palemoon/run-mozilla.sh "$@" -no-remote -wait-forbrowser "$@" >/dev/null 2>&1
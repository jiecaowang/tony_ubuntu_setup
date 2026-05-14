#!/bin/sh
# Exit 0 iff this sudo invocation originated from a Cursor agent shell
# (a process anywhere in the calling-process tree has CURSOR_INVOKED_AS=agent
# in its environment). Wired into /etc/pam.d/sudo via pam_exec so that:
#   - Cursor agent runs sudo without a password
#   - Manual `sudo` in any terminal prompts as usual
#
# Runs as root inside sudo's PAM auth phase, so /proc/$pid/environ is readable
# for every process we visit. Walks at most 24 ancestors to avoid loops.

set -u

walk_pid=${PPID:-0}
i=0
while [ "$walk_pid" -gt 1 ] && [ "$i" -lt 24 ]; do
    if [ -r "/proc/$walk_pid/environ" ]; then
        if tr '\0' '\n' < "/proc/$walk_pid/environ" 2>/dev/null \
            | grep -qx 'CURSOR_INVOKED_AS=agent'; then
            exit 0
        fi
    fi
    walk_pid=$(awk '{print $4; exit}' "/proc/$walk_pid/stat" 2>/dev/null) || exit 1
    i=$((i + 1))
done
exit 1

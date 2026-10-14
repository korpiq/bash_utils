#!/bin/bash
# Usage: kill-activity.sh <activity name> [--kill]
# Lists (default) or SIGTERMs (--kill) processes owning windows that are
# in the named KDE activity, without switching to it.
# Windows shown on all activities are skipped.
set -eu
name=$1
mode=${2:-}

am=org.kde.ActivityManager
id=
for a in $(qdbus6 $am /ActivityManager/Activities org.kde.ActivityManager.Activities.ListActivities); do
  n=$(qdbus6 $am /ActivityManager/Activities org.kde.ActivityManager.Activities.ActivityName "$a")
  [ "$n" = "$name" ] && id=$a
done
[ -n "$id" ] || { echo "no activity named $name" >&2; exit 1; }

js=$(mktemp --suffix=.js)
trap 'rm -f "$js"' EXIT
cat >"$js" <<EOF
for (const w of workspace.windowList()) {
  if (w.normalWindow && w.activities.length === 1 && w.activities[0] === "$id")
    print("ACTIVITY_PID " + w.pid + " " + w.resourceClass + " " + w.caption);
}
EOF

since=$(date '+%Y-%m-%d %H:%M:%S')
sn=kill-activity-$$
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.loadScript "$js" $sn >/dev/null
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.start >/dev/null
sleep 1
qdbus6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript $sn >/dev/null || true

out=$(journalctl --user --since "$since" --no-pager -o cat | grep -o 'ACTIVITY_PID .*' || true)
echo "$out"
if [ "$mode" = --kill ]; then
  echo "$out" | awk '{print $2}' | sort -un | xargs -r kill
fi

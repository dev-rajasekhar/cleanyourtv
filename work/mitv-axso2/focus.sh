# usage: TV_HOST=... sh work/mitv-axso2/focus.sh KEY  -> press KEY once, then print the focused node
k="$1"
tools/venv/bin/python -I tools/tv.py "input keyevent $k; sleep 2; uiautomator dump /data/local/tmp/ui.xml >/dev/null 2>&1; grep -o '<node[^>]*focused=\"true\"[^>]*>' /data/local/tmp/ui.xml | grep -oE '(text|resource-id|content-desc|bounds)=\"[^\"]*\"' | tr '\n' ' '; echo; rm -f /data/local/tmp/ui.xml"

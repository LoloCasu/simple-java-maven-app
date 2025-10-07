#!/bin/bash

LOG_FILE="jenkins_log.txt"

echo "Étapes Jenkins et leur durée :"
echo "-------------------------------"

# Extraire les timestamps et les noms des étapes
grep -E '

\[Pipeline\]

 stage|

\[Pipeline\]

 \{ \(|Finished: SUCCESS' "$LOG_FILE" | \
awk '
  /

\[Pipeline\]

 stage/ { stage_time = last_time }
  /

\[Pipeline\]

 \{ \(/ {
    stage_name = $0
    sub(/^.*\(/, "", stage_name)
    sub(/\).*/, "", stage_name)
    print stage_time, stage_name
  }
  /^

\[[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}/ {
    match($0, /^

\[([0-9T:\.Z-]+)\]

/, arr)
    last_time = arr[1]
  }
' | while read start_time stage_name; do
    # Convertir le timestamp en secondes
    start_sec=$(date -d "$start_time" +%s)
    # Chercher la fin de l'étape
    end_line=$(grep -A 1000 "$start_time" "$LOG_FILE" | grep -m 1 "

\[Pipeline\]

 // stage")
    end_time=$(echo "$end_line" | grep -oP '

\[\K[0-9T:\.Z-]+(?=\]

)')
    end_sec=$(date -d "$end_time" +%s)
    duration=$((end_sec - start_sec))
    echo "🧩 Étape: $stage_name | ⏱️ Durée: ${duration}s"
done

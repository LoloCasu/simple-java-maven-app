 #!/usr/bin/env bash

echo "Analyse des étapes Jenkins" > steps_report.txt
grep -E '\\[Pipeline\\]
 stage|\
\[Pipeline\\]
 \\{ \\(|Finished: SUCCESS' jenkins_log.txt | \
          awk '
            /\
\[Pipeline\\]
 stage/ { stage_time = last_time }
            /\
\[Pipeline\\]
 \\{ \\(/ {
              stage_name = $0
              sub(/^.*\\(/, "", stage_name)
              sub(/\\).*/, "", stage_name)
              print stage_time, stage_name
            }
            /^\
\[[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}/ {
              match($0, /^\
\[([0-9T:\\.Z-]+)\\]
/, arr)
              last_time = arr[1]
            }
          ' >> steps_report.txt
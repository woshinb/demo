cat $file | tr -s '[:space:]' '\n' | sort | uniq -c | sort -nr

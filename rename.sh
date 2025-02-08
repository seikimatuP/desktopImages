#!/bin/bash

# スクリプトが置かれているディレクトリ
base_dir="$(dirname "$0")"
log_file="$base_dir/rename_log.txt"
echo "--- Rename Log $(date) ---" > "$log_file"

# ディレクトリをループ処理
target_dirs=("$base_dir"/*)
for dir in "${target_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        dir_name="$(basename "$dir")"
        count=1
        
        # ディレクトリ内のファイルをループ処理
        for file in "$dir"/*; do
            if [[ -f "$file" ]]; then
                ext="${file##*.}"
                new_name="${dir_name}_${count}.${ext}"
                echo "Renaming: $file -> $dir/$new_name" | tee -a "$log_file"
                mv "$file" "$dir/$new_name"
                ((count++))
            fi
        done
    fi
done

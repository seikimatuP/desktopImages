#!/bin/bash

# スクリプトが置かれているディレクトリ
base_dir="$(dirname "$0")"
log_file="$base_dir/rename_log.txt"
exclude_file="$base_dir/.exclude_dirs"
echo "--- Rename Log $(date) ---" > "$log_file"

# 除外ディレクトリをリスト化
exclude_dirs=()
if [[ -f "$exclude_file" ]]; then
    while IFS= read -r line; do
        exclude_dirs+=("$line")
    done < "$exclude_file"
fi

# ディレクトリをループ処理
target_dirs=("$base_dir"/*)
for dir in "${target_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        dir_name="$(basename "$dir")"
        
        # 除外リストに含まれている場合はスキップ
        if [[ " ${exclude_dirs[*]} " =~ " $dir_name " ]]; then
            echo "Skipping excluded directory: $dir_name" | tee -a "$log_file"
            continue
        fi
        
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

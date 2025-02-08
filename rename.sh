#!/bin/bash

# スクリプトが置かれているディレクトリ
base_dir="$(dirname "$0")"

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
                mv "$file" "$dir/$new_name"
                ((count++))
            fi
        done
    fi
done

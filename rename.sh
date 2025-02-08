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
        # コメント行と空行を無視
        [[ -z "$line" || "$line" =~ ^#.*$ ]] && continue
        exclude_dirs+=("$line")
    done < "$exclude_file"
fi

# 除外ディレクトリがない場合は確認
if [[ ${#exclude_dirs[@]} -eq 0 ]]; then
    read -p "No excluded directories found. Proceed with renaming? (yes/no): " confirm
    if [[ ! "$confirm" =~ ^[Yy]([Ee][Ss])?$ ]]; then
        echo "Operation canceled." | tee -a "$log_file"
        exit 0
    fi
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

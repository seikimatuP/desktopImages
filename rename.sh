#!/bin/bash

# 設定ファイルを読み込む
config_file="$(dirname "$0")/rename_config.conf"
source "$config_file"

# スクリプトが置かれているディレクトリ
base_dir="$(dirname "$0")"
log_file="$base_dir/$log_file_name"
exclude_file="$base_dir/$exclude_file_name"
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

# スクリプトの実行確認
# read -p "Proceed with renaming files in directories? (yes/no): " confirm
# if [[ ! "$confirm" =~ ^[Yy]([Ee][Ss])?$ ]]; then
#     echo "Operation canceled." | tee -a "$log_file"
#     exit 0
# fi

# ディレクトリをループ処理
target_dirs=("$base_dir"/*)
for dir in "${target_dirs[@]}"; do
    if [[ -d "$dir" ]]; then
        dir_name="$(basename "$dir")"
        
        # 除外リストに含まれている場合はスキップ
        if [[ " ${exclude_dirs[*]} " =~ " $dir_name " ]]; then
            continue
        fi
        
        count=1
        flg=false
        # ディレクトリ内のファイルをソートしてループ処理
        for file in $(ls "$dir" | sort -V); do
            file_path="$dir/$file"
            if [[ -f "$file_path" ]]; then

                ext="${file##*.}"
                base_name="${dir_name}_${count}"
                new_name="${base_name}.${ext}"
                
                # ファイル名が重複しないようにチェック（拡張子を抜きで）
                while ls "$dir/${base_name}."* 1> /dev/null 2>&1; do
                    # ファイル名が重複している場合、重複フラグをオンにしてループを抜ける
                    if [[ "$file" == "${base_name}.${ext}" ]]; then
                        echo hoge
                        flg=true
                        break
                    fi
                    ((count++))
                    base_name="${dir_name}_${count}"
                done

                if $flg; then
                    # 重複している場合はスキップ
                    echo "Skipping file due to name conflict: $file_path" | tee -a "$log_file"
                    count=1

                    continue
                fi

                new_name="${base_name}.${ext}"
                echo "Renaming: $file_path -> $dir/$new_name" | tee -a "$log_file"
                if mv "$file_path" "$dir/$new_name"; then
                    echo "Successfully renamed: $file_path -> $dir/$new_name" | tee -a "$log_file"
                else
                    echo "Error renaming: $file_path" | tee -a "$log_file"
                fi
                flg=false
                count=1
            fi
        done
        echo "end file loop"
    fi
done
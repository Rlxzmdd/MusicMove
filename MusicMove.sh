#!/bin/bash

# 打印用法
usage() {
    echo "Usage: $0 -s SOURCE_DIR -o OUTPUT_DIR -n NCMDUMP_PATH -d DELETE_SOURCE"
    echo "  -s SOURCE_DIR     待检测目录"
    echo "  -o OUTPUT_DIR     输出目录"
    echo "  -n NCMDUMP_PATH   ncmdump调用路径"
    echo "  -d DELETE_SOURCE  是否删除源文件 (true or false)"
    exit 1
}

# 初始化统计变量
total_files=0
mp3_count=0
flac_count=0
ncm_count=0

# 解析命令行参数
while getopts "s:o:n:d:" opt; do
    case $opt in
        s) SOURCE_DIR="$OPTARG" ;;
        o) OUTPUT_DIR="$OPTARG" ;;
        n) NCMDUMP_PATH="$OPTARG" ;;
        d) DELETE_SOURCE="$OPTARG" ;;
        *) usage ;;
    esac
done

# 检查所有必需的参数是否都已提供
if [ -z "$SOURCE_DIR" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$NCMDUMP_PATH" ] || [ -z "$DELETE_SOURCE" ]; then
    usage
fi

# 统计待检测目录中的总文件数量（过滤隐藏文件）
total_files=$(find "$SOURCE_DIR" -type f ! -name ".*" | wc -l)

# 检查待检测目录是否存在文件
if [ "$total_files" -eq 0 ]; then
    #logger -p user.info -t MusicMove "[MusicMove] 待检测目录中没有文件。"
    exit 0
fi

# 统计并处理 .mp3 和 .flac 文件（过滤隐藏文件）
mp3_files=$(find "$SOURCE_DIR" -type f -name "*.mp3" ! -name ".*")
flac_files=$(find "$SOURCE_DIR" -type f -name "*.flac" ! -name ".*")
mp3_count=$(echo "$mp3_files" | wc -l)
flac_count=$(echo "$flac_files" | wc -l)

# 移动或复制 .mp3 文件
echo "$mp3_files" | while read -r file; do
    relative_path="${file#$SOURCE_DIR/}"
    output_path="$OUTPUT_DIR/$relative_path"
    output_dir=$(dirname "$output_path")
    mkdir -p "$output_dir"
    if [[ "$DELETE_SOURCE" == "true" ]]; then
        mv "$file" "$output_path"
    else
        cp "$file" "$output_path"
    fi
done

# 移动或复制 .flac 文件
echo "$flac_files" | while read -r file; do
    relative_path="${file#$SOURCE_DIR/}"
    output_path="$OUTPUT_DIR/$relative_path"
    output_dir=$(dirname "$output_path")
    mkdir -p "$output_dir"
    if [[ "$DELETE_SOURCE" == "true" ]]; then
        mv "$file" "$output_path"
    else
        cp "$file" "$output_path"
    fi
done

# 统计并递归处理 .ncm 文件（过滤隐藏文件）
ncm_files=$(find "$SOURCE_DIR" -type f -name "*.ncm" ! -name ".*")
ncm_count=$(echo "$ncm_files" | wc -l)

if [[ "$ncm_count" -gt 0 ]]; then
    "$NCMDUMP_PATH" -d "$SOURCE_DIR" -o "$OUTPUT_DIR" -r > /dev/null 2>&1
fi

# 检查是否删除源文件夹内容
if [[ "$DELETE_SOURCE" == "true" ]]; then
    rm -rf "$SOURCE_DIR"/*
fi

# 输出统计信息到系统日志
logger -p user.info -t MusicMove "[MusicMove] 执行音乐转移统计信息: 总文件数: $total_files, mp3 文件数: $mp3_count, flac 文件数: $flac_count, ncm 文件数: $ncm_count"

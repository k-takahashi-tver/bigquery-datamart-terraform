# 引数はscheduled_query, view など各リソースのディレクトリを想定しています
BASE_PATH=$1

# 連想配列を用意します
declare -A queries

# 引数のディレクトリ配下から settings.json を探してパスを取得します
for settings_file in $(find "$BASE_PATH" -name 'settings.json'); do

    # ディレクトリ名を取得します (scheduled_query/hoge/settings.json の hoge のところ)
    key=$(basename "$(dirname "$settings_file")")
    # settings.json の内容を取り出し、terraform で読み取れるように変換します
    # $ echo '{"foo":"FOO"}' | jq '@json'
    # >> "{\"foo\":\"FOO\"}"

    # dataset_id がオブジェクトの場合はそのまま、文字列の場合は {prd, stg, dev} に展開します
    # dataset_id がない場合はスキップ
    content=$(jq 'if has("dataset_id") then 
                    .dataset_id |= if type == "object" then . 
                    else {prd: ., stg: ., dev: .}
                    end 
                  else . end | @json' "$settings_file")
    # queries に格納します
    queries["$key"]=$content
done

# queries の中身をくっつけていきます
# 先頭と末尾に{}を加えます
result="{"
for key in "${!queries[@]}"; do
    result+="\"$key\": ${queries[$key]},"
done

result="${result%,}}"

# 結果を出力します
echo $result

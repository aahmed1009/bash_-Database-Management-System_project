#!/bin/bash
source "$(dirname "$0")/utils.sh"

insert_into_table() {
    echo "[INSERT INTO TABLE]"
    read -rp "Insert into table: " tname

    if [ ! -f "$tname" ] || [ ! -f "$tname"_meta ]; then
        echo "Table or metadata not found."
        return
    fi

    data=""
    fields=()
    pk_index=-1

    mapfile -t lines < "$tname"_meta
    for ((i = 0; i < ${#lines[@]}; i++)); do
        IFS='|' read -r fname key dtype <<< "${lines[$i]}"
        fields+=("$fname")

        while true; do
            read -rp "$fname ($dtype): " val
            val=$(trim "$val")

            if [[ "$dtype" == "int" && ! "$val" =~ ^[0-9]+$ ]]; then
                echo "Invalid input. '$fname' must be an integer."
                continue
            fi

            if [ "$key" = "pk" ]; then
                pk_index=$((i + 1))
                exists=$(cut -d'|' -f"$pk_index" "$tname" | grep -x "$val")
                if [ -n "$exists" ]; then
                    echo "Primary key must be unique. Value '$val' already exists."
                    continue
                fi
            fi

            data+="$val|"
            break
        done
    done

    echo "${data%|}" >> "$tname"
    echo "Data inserted into '$tname' successfully."
}
select_from_table() {
    echo "[SELECT FROM TABLE]"
    read -rp "Table name: " tname

    if [ ! -f "$tname" ] || [ ! -f "$tname"_meta ]; then
        echo "Table or metadata not found."
        return
    fi

    echo "1) Select all"
    echo "2) Filter by column"
    echo "3) Select specific columns"
    read -rp "Choose: " sel

    case $sel in
        1)
            echo "Full table content:"
            cat "$tname"
            ;;
        2)
            read -rp "Column name: " col
            idx=$(get_column_index "$col" "$tname"_meta)
            if [ -z "$idx" ]; then
                echo "No such column."
                return
            fi
            read -rp "Value to match: " val
            result=$(awk -F'|' -v i="$idx" -v v="$val" '$i == v' "$tname")
            if [ -z "$result" ]; then
                echo "No match found."
            else
                echo "$result"
            fi
            ;;
        3)
            read -rp "Columns (comma-separated): " cols
            IFS=',' read -ra cols_arr <<< "$cols"
            indices=()

            for col in "${cols_arr[@]}"; do
                idx=$(get_column_index "$col" "$tname"_meta)
                if [ -z "$idx" ]; then
                    echo "Column '$col' not found."
                    return
                fi
                indices+=("$idx")
            done

            awk -F'|' -v idxs="${indices[*]}" '{
                split(idxs, arr, " ")
                for (i in arr) printf "%s ", $arr[i]
                print ""
            }' "$tname"
            ;;
        *)
            echo "Invalid option."
            ;;
    esac
}

delete_from_table() {
    echo "[DELETE FROM TABLE]"
    read -rp "Table name: " tname
    if [ ! -f "$tname" ]; then
        echo "Table not found."
        return
    fi

    echo "1) Delete all rows"
    echo "2) Delete by column value"
    read -rp "Choose: " mode

    if [ "$mode" = "1" ]; then
        > "$tname"
        echo "All records deleted."
    elif [ "$mode" = "2" ]; then
        read -rp "Column name: " col
        idx=$(get_column_index "$col" "$tname"_meta)
        if [ -z "$idx" ]; then
            echo "No such column."
            return
        fi
        read -rp "Value to delete: " val
        awk -F'|' -v i="$idx" -v v="$val" '$i != v' "$tname" > tmp && mv tmp "$tname"
        echo "Matching rows deleted."
    else
        echo "Invalid choice."
    fi
}

update_table() {
    echo "[UPDATE TABLE]"
    read -rp "Table name: " tname

    if [ ! -f "$tname" ] || [ ! -f "$tname"_meta ]; then
        echo "Table or metadata not found."
        return
    fi

    read -rp "Column to match: " col
    idx=$(get_column_index "$col" "$tname"_meta)

    if [ -z "$idx" ]; then
        echo "No such column '$col' in table '$tname'."
        return
    fi

    read -rp "Old value: " old
    read -rp "New value: " new

    awk -F'|' -v i="$idx" -v o="$old" -v n="$new" '
    {
        if ($i == o) {
            $i = n
            updated = 1
        }
        print $0
    }
    END {
        if (!updated) {
            print "[No matching value found to update]" > "/dev/stderr"
        }
    }
    ' OFS='|' "$tname" > tmp && mv tmp "$tname"

    echo "Update complete."
}

#!/bin/bash
source "$(dirname "$0")/table_ops.sh"
source "$(dirname "$0")/utils.sh"

validate_name() {
    [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}

while true; do
    echo
    echo "1) Create table"
    echo "2) List all tables"
    echo "3) Drop table"
    echo "4) Insert into table"
    echo "5) Select from table"
    echo "6) Delete from table"
    echo "7) Update table"
    echo "8) Back to DB menu"
    read -rp "Choose an option: " option

    case $option in
        1)
            read -rp "Enter table name: " tname
            if ! validate_name "$tname"; then
                echo "Invalid name format."
                continue
            elif [ -f "$tname" ]; then
                echo "Table already exists."
                continue
            fi
            touch "$tname" "$tname"_meta
            read -rp "Number of fields: " nf
            pk_set=false
            for ((i=1; i<=nf; i++)); do
                read -rp "Field $i name: " fname
                echo -n "$fname|" >> "$tname"_meta
                if [ "$pk_set" = false ]; then
                    read -rp "Primary key? (y/n): " pk
                    if [ "$pk" = "y" ]; then
                        echo -n "pk|" >> "$tname"_meta
                        pk_set=true
                    else
                        echo -n "npk|" >> "$tname"_meta
                    fi
                else
                    echo -n "npk|" >> "$tname"_meta
                fi
                echo "1) string  2) int"
                read -rp "Choose datatype: " dtype
                [[ "$dtype" == "1" ]] && echo "string" >> "$tname"_meta || echo "int" >> "$tname"_meta
            done
            echo "Table '$tname' created successfully."
            ;;
        2)
            echo "Tables:"
            ls | grep -v '_meta$'
            ;;
        3)
            read -rp "Table name to drop: " tname
            if [ -f "$tname" ]; then
                rm "$tname" "$tname"_meta
                echo "Table '$tname' deleted."
            else
                echo "There is no table with this name."
            fi
            ;;
        4)
            insert_into_table
            ;;
        5)
            select_from_table
            ;;
        6)
            delete_from_table
            ;;
        7)
            update_table
            ;;
        8)
            echo "Returning to DB menu..."
            break
            ;;
        *)
            echo "Invalid option. Try again."
            ;;
    esac
done

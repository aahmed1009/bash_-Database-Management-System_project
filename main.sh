#!/bin/bash

DB_DIR="DB"

clear
echo "#########################################"
echo "#             Welcome to DBMS           #"
if [ ! -d "$DB_DIR" ]; then
    mkdir "$DB_DIR"
fi
cd "$DB_DIR" || exit

validate_name() {
    [[ "$1" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]
}

while true; do
    echo
    echo "* 1) Create database"
    echo "* 2) List databases"
    echo "* 3) Drop database"
    echo "* 4) Connect to a database"
    echo "* 5) Exit"
    read -rp "Choose an option: " choice

    case $choice in
        1)
            read -rp "Enter database name: " dbname
            if ! validate_name "$dbname"; then
                echo "Invalid name format"
            elif [ -d "$dbname" ]; then
                echo "This database already exists"
            else
                mkdir "$dbname"
                echo "Database '$dbname' created"
            fi
            ;;
        2)
            echo "Databases:"
            dbs=$(ls -F | grep '/$')
            if [ -z "$dbs" ]; then
                echo "No databases found"
            else
                echo "$dbs"
            fi
            ;;
        3)
            echo "Databases:"
            dbs=$(ls -F | grep '/$')
            if [ -z "$dbs" ]; then
                echo "No databases to delete"
                continue
            fi
            echo "$dbs"
            read -rp "Enter database name to drop: " dbname
            if [ -d "$dbname" ]; then
                rm -r "$dbname"
                echo "Database '$dbname' deleted"
            else
                echo "Database does not exist"
            fi
            ;;
        4)
            echo "Databases:"
            dbs=$(ls -F | grep '/$')
            if [ -z "$dbs" ]; then
                echo "No databases found"
                continue
            fi
            echo "$dbs"
            read -rp "Enter database name to connect: " dbname
            if [ -d "$dbname" ]; then
                echo "Connected to '$dbname'"
                cd "$dbname" || continue
                ../../table_menu.sh
                echo "Disconnected from '$dbname'"
                cd ..
            else
                echo "No database with this name"
            fi
            ;;
        5)
            echo "Goodbye"
            break
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
done


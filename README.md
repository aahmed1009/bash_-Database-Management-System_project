# Bash Database Management System (DBMS)

This project is a simple database management system built using Bash scripts. It stores data using folders and text files. You can create databases, tables, and perform actions like insert, update, delete, and select records.

## Features

* Create and delete databases
* Create, list, and delete tables
* Insert new records
* View all records or filter by column
* Update existing records
* Delete all records or filter by column
* Primary key and data type validation
* Simple command-line menus

## How it works

* Each database is a folder inside the `DB` folder.
* Each table is a file inside its database folder.
* Each table has two files:

  * `table_name` (for data)
  * `table_name_meta` (for column names, types, and keys)

## Folder Structure

```
project/
├── main.sh          # Main menu to manage databases
├── table_menu.sh    # Menu to manage tables inside a database
├── table_ops.sh     # Functions for insert, select, update, delete
├── utils.sh         # Helper functions for validation
└── DB/              # Created automatically to store databases
```

## How to run

1. Open a terminal

2. Go to the project folder

3. Make scripts executable:

   ```bash
   chmod +x *.sh
   ```

4. Start the system:

   ```bash
   ./main.sh
   ```

Follow the menus step by step. First create a database, then connect to it, then create a table, and start inserting records.

## Flow

1. Run `main.sh`
2. Choose option `1` to create a database (example: `school`)
3. Choose option `4` to connect to that database
4. In the new menu, choose `1` to create a table (example: `students`)
5. Add fields and types (id as int and primary key, name as string, etc.)
6. Choose `4` to insert data
7. Choose `5` to select and view data

## Notes

* Primary key must be unique
* Data is stored using `|` separator
* Strings must not contain `|`

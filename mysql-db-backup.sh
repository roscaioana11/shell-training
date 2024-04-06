#!/bin/bash

# Scheduling a script to run on a specific period of time
# Command: crontab -e
# Add the following line at the end of the file: 0 18 * * 0 /path/to/your/script/backup_mysql.sh
# The above scheduling means that this 'cron' will execute the script every Sunday at 6 PM.
#   - '0' represents the minute (0 minutes past the hour).
#   - '18' represents the hour (6 PM in 24-hour format).
#   - '* * 0' represents any day of the month, any month, and 0 represents Sunday.

# Before running this script we want the DB credentials, username and password, to be encrypted:
# Command:
# echo -n "your_username:your_password" | openssl aes-256-cbc -salt -out /path/to/encrypted/credentials.txt.enc

# Function to start MariaDB service if it's not already running
start_mariadb_service() {
    systemctl start mariadb.service
}

# Check if MariaDB service is running
if systemctl is-active --quiet mariadb.service; then
    echo "MariaDB service is running"
else
    echo "MariaDB service is not running, starting the service..."
    start_mariadb_service

    # Check if MariaDB service started successfully
    if systemctl is-active --quiet mariadb.service; then
        echo "MariaDB service started successfully"
    else
        echo "Error: Failed to start MariaDB service"
        exit 1  # Exit with error code
    fi
fi

# Path to encrypted credentials file
ENCRYPTED_CREDENTIALS_FILE="/home/ioana/mysql_db_backup/encrypted/credentials.txt.enc"

# Decrypting credentials
decrypted_credentials=$(openssl aes-256-cbc -d -in $ENCRYPTED_CREDENTIALS_FILE)

# MariaDB database credentials
DB_USER=$(echo $decrypted_credentials | cut -d':' -f1)
DB_PASS=$(echo $decrypted_credentials | cut -d':' -f2)
DB_NAME="your_database_name"

# Backup directory
BACKUP_DIR="/home/ioana/mysql_db_backup"

# Maximum number of retries
MAX_RETRIES=3

# Timestamp for backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Backup filename
BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql"

# Function to perform MariaDB backup
perform_backup() {
    # Command to backup MariaDB database
    mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_FILE
}

# Attempt backup with retries
attempt=1
while [ $attempt -le $MAX_RETRIES ]; do
    echo "Attempt $attempt of $MAX_RETRIES"
    perform_backup

    # Check if the backup was successful
    if [ $? -eq 0 ]; then
        echo "Backup of database '$DB_NAME' completed successfully: $BACKUP_FILE"
        break
    else
        echo "Error: Backup of database '$DB_NAME' failed!"
        echo "Retrying..."
        ((attempt++))
    fi
done

# Check if maximum retries reached
if [ $attempt -gt $MAX_RETRIES ]; then
    echo "Maximum retries reached. Backup failed."
    exit 1  # Exit with error code
fi

# Check if backup file exists
if [ ! -f $BACKUP_FILE ]; then
    echo "Backup file '$BACKUP_FILE' not found."
    exit 1  # Exit with error code
fi

# Check if backup file size is zero
if [ ! -s $BACKUP_FILE ]; then
    echo "Backup file '$BACKUP_FILE' is empty."
    exit 1  # Exit with error code
fi

echo "Backup process completed successfully."



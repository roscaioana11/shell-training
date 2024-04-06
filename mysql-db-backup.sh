#!/bin/bash

# Function to start MySQL service if it's not already running
start_mysql_service() {
  # Adjust the command based on your MySQL service name
    systemctl start mysql.service
}

# Check if MySQL service is running
if systemctl is-active --quiet mysql.service; then
    echo "MySQL service is running"
else
    echo "MySQL service is not running, starting the service..."
    start_mysql_service

    # Check if MySQL service started successfully
    if systemctl is-active --quiet mysql.service; then
        echo "MySQL service started successfully"
    else
        echo "Error: Failed to start MySQL service"
        exit 1  # Exit with error code
    fi
fi

# Path to encrypted credentials file
ENCRYPTED_CREDENTIALS_FILE="/path/to/encrypted/credentials.txt.enc"

# Decrypting credentials
decrypted_credentials=$(openssl aes-256-cbc -d -in $ENCRYPTED_CREDENTIALS_FILE)

# MySQL database credentials
DB_USER=$(echo $decrypted_credentials | cut -d':' -f1)
DB_PASS=$(echo $decrypted_credentials | cut -d':' -f2)
DB_NAME="your_database_name"

# Backup directory
BACKUP_DIR="/path/to/backup/directory"

# Maximum number of retries
MAX_RETRIES=3

# Timestamp for backup file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Backup filename
BACKUP_FILE="$BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql"

# Function to perform MySQL backup
perform_backup() {
    # Command to backup MySQL database
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

#!/usr/bin/env bash

echo "Welcome to the admin script"

while true; do
    echo "1. Create a new user"
    echo "2. Add user to group"
    echo "3. Change user permissions"
    echo "4. Exit"

    read -p "Select an option: " choice

    case $choice in
    1)
      read -p "Enter username: " username
      sudo useradd $username
      echo "User $username created successfully"
      ;;
    2)
      read -p "Enter username: " username
      read -p "Enter group name: " groupname
      sudo usermod -a -G $groupname $username
      echo "User $username added to group $groupname"
      ;;
    3)
      read -p "Enter username: " username
      read -p "Enter new permission (e.g. rwx): " perm
      sudo chmod $perm /home/$username
      echo "Permission changed for $username"
      ;;
    4)
      echo "Exiting admin script"
      break
      ;;
    *)
      echo "Invalid choice. Please try again"
    esac
done

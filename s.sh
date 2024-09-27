#!/bin/bash

# Colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
purple='\033[0;35m'
rest='\033[0m'

# Check if warp command exists
if ! command -v warp &> /dev/null; then
    echo -e "${red}Error: Warp is not installed. Please install Warp first.${rest}"
    exit 1
fi

# Create the service file for warp
create_service() {
    echo -e "${purple}Creating systemd service for Warp...${rest}"

    SERVICE_CONTENT="[Unit]
Description=WARP+ VPN Service
After=network.target

[Service]
Type=simple
ExecStart=$(command -v warp)
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target"

    # Write the service content to a new file in /etc/systemd/system/
    echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/warp.service > /dev/null

    # Reload systemd, enable and start the service
    sudo systemctl daemon-reload
    sudo systemctl enable warp.service
    sudo systemctl start warp.service

    echo -e "${green}Warp service created and started successfully.${rest}"
}

# Check service status
check_status() {
    sudo systemctl status warp.service
}

# Main Menu
menu() {
    echo -e "${green}Warp Service Manager${rest}"
    echo ""
    echo -e "${yellow}1) Create and start Warp service${rest}"
    echo -e "${yellow}2) Check Warp service status${rest}"
    echo -e "${yellow}3) Stop and disable Warp service${rest}"
    echo -e "${yellow}0) Exit${rest}"
}

# Stop and disable the service
stop_service() {
    echo -e "${purple}Stopping and disabling Warp service...${rest}"
    sudo systemctl stop warp.service
    sudo systemctl disable warp.service
    echo -e "${green}Warp service stopped and disabled.${rest}"
}

# Main logic
while true; do
    menu
    read -p "Select an option: " choice

    case "$choice" in
        1)
            create_service
            ;;
        2)
            check_status
            ;;
        3)
            stop_service
            ;;
        0)
            echo -e "${green}Exiting...${rest}"
            exit 0
            ;;
        *)
            echo -e "${red}Invalid choice. Please select a valid option.${rest}"
            ;;
    esac
done

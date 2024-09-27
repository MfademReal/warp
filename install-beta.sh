#!/bin/bash

# Colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
purple='\033[0;35m'
cyan='\033[0;36m'
rest='\033[0m'

# Check Dependencies
check_dependencies() {
    local dependencies=("curl" "openssl" "wget" "unzip" "openssh-server" "golang")

    for dep in "${dependencies[@]}"; do
        if ! dpkg -s "${dep}" &> /dev/null; then
            echo -e "${yellow}${dep} is not installed. Installing...${rest}"
            sudo apt update
            sudo apt install -y "${dep}"
        fi
    done
}

# Install
install() {
    if command -v warp &> /dev/null || command -v usef &> /dev/null; then
        echo -e "${green}Warp is already installed.${rest}"
        return
    fi

    echo -e "${purple}*********************************${rest}"
    echo -e "${green}Installing Warp...${rest}"
    sudo apt update
    sudo apt upgrade -y
    check_dependencies

    if wget https://github.com/bepass-org/warp-plus/releases/download/v1.1.3/warp-plus_linux-amd64.zip &&
        unzip warp-plus_linux-amd64.zip &&
        mv warp-plus warp &&
        chmod +x warp &&
        sudo cp warp /usr/local/bin/usef &&
        sudo cp warp /usr/local/bin/warp-plus &&
        sudo cp warp /usr/local/bin/warp; then
        rm "README.md" "LICENSE" "warp-plus_linux-amd64.zip"
        echo "================================================"
        echo -e "${green}Warp installed successfully.${rest}"
        create_service
        socks
    else
        echo -e "${red}Error installing Warp.${rest}"
    fi
}

# Create the service
create_service() {
    echo -e "${purple}Creating systemd service...${rest}"

    # Service configuration content
    SERVICE_CONTENT="[Unit]
Description=WARP+ VPN Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/warp
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target"

    # Create the service file
    echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/warpplus.service > /dev/null

    # Reload systemd, enable and start the service
    sudo systemctl daemon-reload
    sudo systemctl enable warpplus.service
    sudo systemctl start warpplus.service

    echo -e "${green}Service created and started successfully.${rest}"
}

# Get socks config
socks() {
   echo ""
   echo -e "${yellow}Copy this Config to ${purple}V2ray${green} Or ${purple}Nekobox ${yellow}and Exclude Ubuntu${rest}"
   echo ""
   echo -e "${green}socks://Og==@localhost:8086#warp_(usef)${rest}"
   echo "or"
   echo -e "${green}Manually create a SOCKS configuration with IP ${purple}localhost ${green}and port${purple} 8086..${rest}"
   echo -e "${blue}================================================${rest}"
   echo -e "${yellow}To run again, type:${green} warp ${rest}or${green} usef ${rest}or${green} ./warp ${rest}or${green} warp-plus ${rest}"
   echo -e "${blue}================================================${rest}"
   echo ""
}

# Uninstall
uninstall() {
    if [ -f "/usr/local/bin/warp" ]; then
        sudo rm -rf "/usr/local/bin/usef" "/usr/local/bin/warp-plus" "/usr/local/bin/warp"
        sudo systemctl stop warpplus.service
        sudo systemctl disable warpplus.service
        sudo rm /etc/systemd/system/warpplus.service
        sudo systemctl daemon-reload
        echo -e "${purple}*********************************${rest}"
        echo -e "${red}Uninstallation completed.${rest}"
        echo -e "${purple}*********************************${rest}"
    else
        echo -e "${yellow} ____________________________________${rest}"
        echo -e "${red} Not installed. Please Install First.${rest}${yellow}|"
        echo -e "${yellow} ____________________________________${rest}"
    fi
}

# Menu
menu() {
    clear
    echo -e "${green}By --> Mfadem * ${rest}"
    echo ""
    echo -e "${yellow}❤️ Powered by Github.com/${cyan}bepass-org${yellow}/warp-plus❤️${rest}"
    echo -e "${purple}*********************************${rest}"
    echo -e "${blue}  ###${cyan} Warp-Plus in Ubuntu ${blue}###${rest} ${purple}  * ${rest}"
    echo -e "${purple}*********************************${rest}"
    echo -e "${cyan}1]${rest} ${green}Install Warp (vpn)${purple}           * ${rest}"
    echo -e "                              ${purple}  * ${rest}"
    echo -e "${cyan}2]${rest} ${green}Uninstall${rest}${purple}                    * ${rest}"
    echo -e "                              ${purple}  * ${rest}"
    echo -e "${red}0]${rest} ${green}Exit                         ${purple}* ${rest}"
    echo -e "${purple}*********************************${rest}"
}

# Main
menu
echo -en "${cyan}Please enter your selection [${yellow}0-2${green}]:${rest}"
read -r choice

case "$choice" in
   1)
        install
        ;;
    2)
        uninstall
        ;;
    0)
        echo -e "${purple}*********************************${rest}"
        echo -e "${cyan}By 🖐${rest}"
        exit
        ;;
    *)
        echo -e "${purple}*********************************${rest}"
        echo -e "${red}Invalid choice. Please select a valid option.${rest}"
        echo -e "${purple}*********************************${rest}"
        ;;
esac

#!/bin/bash

# Helper function to restart haproxy
restart_haproxy() {
    echo "Restarting HAProxy..."
    sudo systemctl restart haproxy
}

# Helper function to start haproxy
start_haproxy() {
    echo "Starting HAProxy..."
    sudo systemctl start haproxy
}

# Helper function to stop haproxy
stop_haproxy() {
    echo "Stopping HAProxy..."
    sudo systemctl stop haproxy
}

# Helper function to install haproxy
install_haproxy() {
    echo "Installing HAProxy..."
    sudo apt update -y
    sudo apt install haproxy -y
}

# Helper function to configure haproxy
configure_haproxy() {
    echo "Configuring HAProxy..."
    config_file="/etc/haproxy/haproxy.cfg"
    echo "global" > $config_file
    echo "   log \"stdout\" format rfc5424 daemon  notice" >> $config_file
    echo "" >> $config_file
    echo "defaults" >> $config_file
    echo "   mode tcp" >> $config_file
    echo "   log global" >> $config_file
    echo "   balance leastconn" >> $config_file
    echo "   timeout connect 5s" >> $config_file
    echo "   timeout server 30s" >> $config_file
    echo "   timeout client 30s" >> $config_file
    echo "   default-server inter 15s" >> $config_file
    echo "" >> $config_file

    while true; do
        echo "Enter the tunnel numbers you want to configure (space-separated, e.g., 1 2 3):"
        read -r tunnel_numbers
        if [ -n "$tunnel_numbers" ]; then
            break
        else
            echo "Tunnel numbers cannot be empty. Please try again."
        fi
    done

    for tunnel_number in $tunnel_numbers; do
        if [[ $tunnel_number -ge 1 && $tunnel_number -le 9 ]]; then
            while true; do
                echo "Enter the ports for tunnel $tunnel_number (space-separated):"
                read -r ports
                if [ -n "$ports" ]; then
                    break
                else
                    echo "Ports cannot be empty. Please try again."
                fi
            done

            echo "frontend tunnel${tunnel_number}-frontend" >> $config_file
            for port in $ports; do
                echo "   bind *:$port" >> $config_file
            done
            echo "   log global" >> $config_file
            echo "   use_backend tunnel${tunnel_number}-backend-servers" >> $config_file
            echo "" >> $config_file

            echo "backend tunnel${tunnel_number}-backend-servers" >> $config_file
            echo "   server tunnel${tunnel_number} [2002:fb8:22${tunnel_number}::2]" >> $config_file
            echo "" >> $config_file
        else
            echo "Invalid tunnel number: $tunnel_number. Valid range is 1-9. Skipping..."
        fi
    done

    restart_haproxy
}

# Function to install and configure netplan
install_netplan() {
    echo "Installing and configuring netplan..."
    sudo apt install netplan.io -y
    sudo systemctl unmask systemd-networkd.service
    sudo systemctl restart networking
    sudo netplan apply
    sudo systemctl restart networking
    sudo netplan apply
    sudo systemctl restart networking
    sudo netplan apply
    echo "Netplan installation and configuration complete."
}

# Function to display the tunnel menu
display_tunnel_menu() {
    echo "Select an option:"
    echo "1 - Install Tunnel"
    echo "2 - Server Iran (IR)"
    echo "3 - Server Kharej (KH)"
    echo "4 - Delete Tunnel"
    echo "5 - Back to Main Menu"
}

# Function to handle the deletion of the tunnel
delete_tunnel() {
    while true; do
        read -p "Enter the tunnel number to delete: " TUNNEL_NUMBER
        FILE_PATH="/etc/netplan/tunnel${TUNNEL_NUMBER}.yaml"

        if [ -n "$TUNNEL_NUMBER" ]; then
            if [ -f "$FILE_PATH" ]; then
                echo "Deleting the file ${FILE_PATH}..."
                sudo rm "$FILE_PATH"
                sudo netplan apply
                echo "Tunnel ${TUNNEL_NUMBER} deleted."
                break
            else
                echo "File ${FILE_PATH} does not exist. Please try again."
            fi
        else
            echo "Tunnel number cannot be empty. Please try again."
        fi
    done

    while true; do
        read -p "Do you want to reboot the server now? (y/n): " REBOOT_ANSWER
        case $REBOOT_ANSWER in
            [Yy]* )
                echo "Rebooting the server..."
                sudo reboot
                exit 0
                ;;
            [Nn]* )
                echo "Server will not be rebooted. Applying netplan configuration again..."
                sudo netplan apply
                exit 0
                ;;
            * )
                echo "Please answer y or n."
                ;;
        esac
    done
}

# Function to handle the creation or updating of a tunnel
create_or_update_tunnel() {
    while true; do
        read -p "Enter the tunnel number: " TUNNEL_NUMBER
        if [ -n "$TUNNEL_NUMBER" ]; then
            break
        else
            echo "Tunnel number cannot be empty. Please try again."
        fi
    done

    FILE_PATH="/etc/netplan/tunnel${TUNNEL_NUMBER}.yaml"

    while true; do
        read -p "Enter the local IP address: " LOCAL_IP
        if [ -n "$LOCAL_IP" ]; then
            break
        else
            echo "Local IP address cannot be empty. Please try again."
        fi
    done

    while true; do
        read -p "Enter the remote IP address: " REMOTE_IP
        if [ -n "$REMOTE_IP" ]; then
            break
        else
            echo "Remote IP address cannot be empty. Please try again."
        fi
    done

    if [ "$SERVER_TYPE" == "ir" ]; then
        ADDRESS="2002:fb8:22${TUNNEL_NUMBER}::1/64"
    elif [ "$SERVER_TYPE" == "kh" ]; then
        ADDRESS="2002:fb8:22${TUNNEL_NUMBER}::2/64"
    else
        echo "Invalid server type. Exiting..."
        exit 1
    fi

    NEW_CONTENT="network:
  version: 2
  tunnels:
    tunnel${TUNNEL_NUMBER}:
      mode: sit
      local: ${LOCAL_IP}
      remote: ${REMOTE_IP}
      addresses:
        - ${ADDRESS}"

    if [ -f "$FILE_PATH" ]; then
        echo "Backing up the existing file to ${FILE_PATH}.bak"
        sudo cp "$FILE_PATH" "${FILE_PATH}.bak"
    fi

    echo "$NEW_CONTENT" | sudo tee "$FILE_PATH" > /dev/null
    sudo netplan apply

    while true; do
        read -p "Do you want to reboot the server now? (y/n): " REBOOT_ANSWER
        case $REBOOT_ANSWER in
            [Yy]* )
                echo "Rebooting the server..."
                sudo reboot
                exit 0
                ;;
            [Nn]* )
                echo "Server will not be rebooted. Applying netplan configuration again..."
                sudo netplan apply
                exit 0
                ;;
            * )
                echo "Please answer y or n."
                ;;
        esac
    done
}

# Main script logic
while true; do
    clear
    echo "Select an option:"
    echo "1 - Tunnel Management"
    echo "2 - HAProxy Management"
    echo "3 - Exit"
    read -r main_option

    case $main_option in
        1)
            while true; do
                clear
                display_tunnel_menu
                read -r tunnel_option

                case $tunnel_option in
                    1)
                        install_netplan
                        ;;
                    2)
                        SERVER_TYPE="ir"
                        create_or_update_tunnel
                        ;;
                    3)
                        SERVER_TYPE="kh"
                        create_or_update_tunnel
                        ;;
                    4)
                        delete_tunnel
                        ;;
                    5)
                        echo "Returning to main menu..."
                        break
                        ;;
                    *)
                        echo "Invalid option. Please try again."
                        ;;
                esac
                echo "Press any key to continue..."
                read -n 1
            done
            ;;
        2)
            while true; do
                clear
                echo "Select an option for HAProxy:"
                echo "1 - Install"
                echo "2 - Configure HAProxy"
                echo "3 - Start HAProxy"
                echo "4 - Stop HAProxy"
                echo "5 - Back to Main Menu"
                read -r haproxy_option

                case $haproxy_option in
                    1)
                        install_haproxy
                        ;;
                    2)
                        configure_haproxy
                        ;;
                    3)
                        start_haproxy
                        ;;
                    4)
                        stop_haproxy
                        ;;
                    5)
                        echo "Returning to main menu..."
                        break
                        ;;
                    *)
                        echo "Invalid option. Please try again."
                        ;;
                esac
                echo "Press any key to continue..."
                read -n 1
            done
            ;;
        3)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
done

#!/usr/bin/env bash
set -eo pipefail

# Global Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
NERD_FONTS_VERSION="3.2.1"

# Initialize status variables for each installation option
gogh_status="Install Gogh [ ]"
nerd_fonts_status="Install Nerd Fonts [ ]"
starship_status="Install Starship [ ]"
ble_sh_status="Install ble.sh [ ]"

# Function to install Gogh
install_gogh() {
    echo "Installing Gogh..."
    if bash -c "$(wget -qO- https://git.io/vQgMr)"; then
        gogh_status="Install Gogh [✔]"
    else
        gogh_status="Install Gogh [✘]"
    fi
}

# Function to install Nerd Fonts
install_nerd_fonts() {
    echo "Installing Nerd Fonts..."
    declare -a fonts=(
        Ubuntu
        UbuntuMono
    )
    fonts_dir="${HOME}/.local/share/fonts"
    if [[ ! -d "$fonts_dir" ]]; then
        mkdir -p "$fonts_dir"
    fi
    for font in "${fonts[@]}"; do
        zip_file="${font}.zip"
        download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${NERD_FONTS_VERSION}/${zip_file}"
        echo "Downloading $download_url"
        wget "$download_url"
        unzip "$zip_file" -d "$fonts_dir"
        rm "$zip_file"
    done
    find "$fonts_dir" -name '*Windows Compatible*' -delete
    fc-cache -fv
    if [[ $? -eq 0 ]]; then
        nerd_fonts_status="Install Nerd Fonts [✔]"
    else
        nerd_fonts_status="Install Nerd Fonts [✘]"
    fi
}

# Function to install Starship
install_starship() {
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh
    echo 'eval "$(starship init bash)"' >> ~/.bashrc
    echo "Replace starship.toml file..." 
    cp -f "$SCRIPT_DIR/starship/starship.toml" ~/.config/
    if [[ $? -eq 0 ]]; then
        starship_status="Install Starship [✔]"
    else
        starship_status="Install Starship [✘]"
    fi
}

# Function to install ble.sh
install_ble_sh() {
    echo "Installing ble.sh prerequisites and running make..."
    sudo apt install make gawk
    git clone --recursive https://github.com/akinomyoga/ble.sh.git
    cd ble.sh || exit
    echo "Installing ble.sh..."
    make install
    if grep -Fxq "[[ $- == *i* ]] && source ~/.local/share/blesh/ble.sh --noattach" ~/.bashrc; then 
      echo "Entry is present, skipping ~/.bashrc modification..."
    else   
      echo "Adding ble.sh source config to .bashrc..."
      sed -i "1i [[ \$- == *i* ]] && source ~/.local/share/blesh/ble.sh --noattach" ~/.bashrc
      echo "[[ \${BLE_VERSION-} ]] && ble-attach" >> ~/.bashrc
    fi
    if grep -Fxq "[[ ${BLE_VERSION-} ]] && ble-attach" ~/.bashrc; then
      echo "Entry is present, skipping ~/.bashrc modification..."
    else 
      echo "Adding ble.sh attach config to .bashrc..."
      echo "[[ \${BLE_VERSION-} ]] && ble-attach" >> ~/.bashrc  
    fi    
    if [[ $? -eq 0 ]]; then
        ble_sh_status="Install ble.sh [✔]"
        rm -rf ble.sh
    else
        ble_sh_status="Install ble.sh [✘]"
        rm -rf ble.sh
    fi
}

#Function to install all 
install_all() {
  install_gogh
  install_nerd_fonts
  install_starship
  install_ble_sh
}

# Main function to display the menu
main_menu() {
echo "
   _____ __         ____  ______            _____      
  / ___// /_  ___  / / / / ____/___  ____  / __(_)___ _
  \__ \/ __ \/ _ \/ / / / /   / __ \/ __ \/ /_/ / __ '/
 ___/ / / / /  __/ / / / /___/ /_/ / / / / __/ / /_/ / 
/____/_/ /_/\___/_/_/  \____/\____/_/ /_/_/ /_/\__, /  
                                              /____/        
                                                                  
Author: https://github.com/data-tangles                                                                                                            
"

    echo "1. $gogh_status"
    echo "2. $nerd_fonts_status"
    echo "3. $starship_status"
    echo "4. $ble_sh_status"
    echo "5. Install all"
    echo "6. Exit"
}

# Loop to handle user input
while true; do
    main_menu
    read -rp "Select an option: " choice

    case $choice in
        1)
            install_gogh
            ;;
        2)
            install_nerd_fonts
            ;;
        3)
            install_starship
            ;;
        4)
            install_ble_sh
            ;;
        5)
            install_all
            break
            ;;
        6)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid option"
            ;;
    esac

    read -rp "Do you want to return to the menu? (y/n): " continue_choice
    if [[ "$continue_choice" != "y" ]]; then
        echo "Exiting..."
        exit 0
    fi
done


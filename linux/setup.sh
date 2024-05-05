#!/usr/bin/env sh

echo "Installing Gogh..."

bash -c "$(wget -qO- https://git.io/vQgMr)"

echo "Installing Starship..."

curl -sS https://starship.rs/install.sh | sh

echo "Adding config to .bashrc file..."

echo 'eval "$(starship init bash)"' >> ~/.bashrc

echo "Replace starship.toml file..." 

cp -f ./linux/starship/starship.toml ~/.config/

echo "Install ble.sh prerequisites and run make..."

sudo apt install gawk

git clone --recursive https://github.com/akinomyoga/ble.sh.git
cd ble.sh || exit
make

echo "Install ble.sh..."

make install

echo "Add ble.sh config to .bashrc..."

sed -e "[[ $- == *i* ]] && source ~/.local/share/blesh --noattach" ~/.bashrc
echo "[[ ${BLE_VERSION-} ]] && ble-attach" >> ~/.bashrc

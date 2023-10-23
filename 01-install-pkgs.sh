source $(dirname "$0")/scripts/library.sh
clear
echo "  ___           _        _ _  "
echo " |_ _|_ __  ___| |_ __ _| | | "
echo "  | ||  _ \/ __| __/ _  | | | "
echo "  | || | | \__ \ || (_| | | | "
echo " |___|_| |_|___/\__\__,_|_|_| "
echo "                              "
echo "by marbonestu (2023)"
echo "-------------------------------------"
echo ""

# ------------------------------------------------------
# Check if yay is installed
# ------------------------------------------------------
if sudo pacman -Qs yay >/dev/null; then
	echo "yay is installed. You can proceed with the installation"
else
	echo "yay is not installed. Will be installed now!"
	_installPackagesPacman "base-devel"
	git clone https://aur.archlinux.org/yay-git.git ~/yay-git
	cd ~/yay-git
	makepkg -si
	cd ~/dotfiles/
	clear
	echo "yay has been installed successfully."
fi

packagesPacman=(
	"pacman-contrib"
	"kitty"
	"stow"
	"wofi"
	"nitrogen"
	"dunst"
	"starship"
	"neovim"
	"mpv"
	"freerdp"
	"xfce4-power-manager"
	"thunar"
	"ttf-font-awesome"
	"ttf-fira-sans"
	"ttf-fira-code"
	"ttf-firacode-nerd"
	"ttf-jetbrains-mono-nerd"
	"figlet"
	"vlc"
	"exa"
	"python-pip"
	"python-pipx"
	"python-psutil"
	"python-rich"
	"python-click"
	"xdg-desktop-portal-gtk"
	"pavucontrol"
	"brightnessctl"
	"tumbler"
	"xautolock"
	"blueman"
	"sddm"
	"papirus-icon-theme"
)

packagesYay=(
	"firefox"
	"slack-desktop-wayland"
	"lazygit"
	"1password"
	"fd"
	"ripgrep"
	"git-delta"
	"discord"
	"zoxide"
	"fzf"
	"sddm-sugar-dark"
)

# ------------------------------------------------------
# Install required packages
# ------------------------------------------------------
_installPackagesPacman "${packagesPacman[@]}"
_installPackagesYay "${packagesYay[@]}"

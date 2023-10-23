source $(dirname "$0")/scripts/library.sh

# ------------------------------------------------------
# Install required packages
# ------------------------------------------------------
echo ""
echo "-> Install main packages"
packagesPacman=(
	"hyprland-nvidia"
	"xdg-desktop-portal-wlr"
	"waybar"
	"wofi"
	"grim"
	"slurp"
	"swayidle"
	"swappy"
	"cliphist"
)

packagesYay=(
	"swww"
	"swaylock-effects"
	"wlogout"
)

# TODO: configure nvidia for hyprland

# ------------------------------------------------------
# Install required packages
# ------------------------------------------------------
_installPackagesPacman "${packagesPacman[@]}"
_installPackagesYay "${packagesYay[@]}"

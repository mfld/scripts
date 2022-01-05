#!/bin/bash
# 1) Download the Krita AppImage from https://www.krita.org
# 2) Run this script in the same directory as the AppiImage

ErrorExit() {
	echo "Error: $1"
	echo ""
	exit 1
}

unset -v krita_latest
for file in krita-*appimage; do
  [[ $file -nt $latest ]] && krita_latest=$file
done

[[ -n $krita_latest ]] ||
  ErrorExit "Krita AppImage not found"

echo "Latest version is $krita_latest"
echo "setting up ..."
chmod +x "$krita_latest"

[[ $(readlink krita) = "$krita_latest" ]] ||
	rm -f krita
[[ -L krita ]] ||
	ln -s "$krita_latest" krita

[[ -d ~/.local/share/applications/ ]] ||
	mkdir ~/.local/share/applications/
[[ -f ~/.local/share/applications/krita.desktop ]] ||
	/bin/cat <<- EOF > ~/.local/share/applications/krita.desktop
	[Desktop Entry]
	Type=Application
	Encoding=UTF-8
	Name=Krita
	Comment=Digital Painting
	Exec=$PWD/krita %F
	Terminal=false
	Icon=krita
	Terminal=false
	EOF

[[ -d ~/.local/share/icons/hicolor/scalable/apps/ ]] ||
	mkdir -p ~/.local/share/icons/hicolor/scalable/apps/
if [[ ! -f ~/.local/share/icons/hicolor/scalable/apps/krita.png ]]; then
	"$PWD/$krita_latest" --appimage-extract krita.png > /dev/null
	mv "$PWD/squashfs-root/krita.png" ~/.local/share/icons/hicolor/scalable/apps/krita.png
	rmdir squashfs-root
fi

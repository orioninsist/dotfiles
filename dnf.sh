#!/bin/bash

package_list="packages.txt"


while IFS= read -r package; do
  echo "Installing: $package"
  sudo dnf install "$package" -y
done < "$package_list"

echo "All packages installed."

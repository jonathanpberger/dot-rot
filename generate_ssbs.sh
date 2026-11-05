#!/bin/bash

# Install yq for parsing YAML if not installed
if ! command -v yq &> /dev/null; then
    echo "yq not found, installing..."
    brew install yq
fi

# Check for ImageMagick and librsvg dependencies
if ! command -v convert &> /dev/null || ! command -v rsvg-convert &> /dev/null; then
    echo "ImageMagick or librsvg not found, installing..."
    brew install imagemagick librsvg
fi

CONFIG_FILE="ssb_config.yaml"
LAUNCHER_DIR="$HOME/ssb_launchers"
APPLICATIONS_DIR="$HOME/Applications"

# Define a list of random emojis
EMOJI_LIST=("🌐" "📚" "💻" "📱" "🚀" "🧩" "⚙️" "🔍" "🌈" "🔒" "✨" "📝" "📁")

# Create directories if they don't exist
mkdir -p "$LAUNCHER_DIR" "$APPLICATIONS_DIR"

# Loop over each SSB entry in YAML and generate the launcher
yq e '.ssbs[]' "$CONFIG_FILE" | while IFS= read -r line; do
  name=$(echo "$line" | yq e '.name' -)
  icon=$(echo "$line" | yq e '.icon' -)
  icon_emoji=$(echo "$line" | yq e '.icon_emoji' -)
  url=$(echo "$line" | yq e '.url' -)
  browser=$(echo "$line" | yq e '.browser' -)
  profile=$(echo "$line" | yq e '.profile' -)

  # Check if an icon path or emoji is specified
  if [[ -z "$icon" && -z "$icon_emoji" ]]; then
    # Pick a random emoji if none specified
    icon_emoji=${EMOJI_LIST[$RANDOM % ${#EMOJI_LIST[@]}]}
  fi

  # Generate icon from emoji if no icon path is specified
  if [[ -z "$icon" ]]; then
    icon="$LAUNCHER_DIR/${name}_icon.png"
    convert -background none -fill black -font AppleColorEmoji -pointsize 128 label:"$icon_emoji" "$icon"
    icon_icns="${icon%.png}.icns"
    sips -s format icns "$icon" --out "$icon_icns"
    icon="$icon_icns"
  fi

  # Create the script for launching the profile
  SCRIPT_PATH="$LAUNCHER_DIR/${name}_launcher.sh"
  cat > "$SCRIPT_PATH" << EOF
#!/bin/bash
if [ "$browser" == "Firefox" ]; then
    open -na "$browser" --args -P "$profile" "$url"
else
    open -na "$browser" --args --profile-directory="$profile" "$url"
fi
EOF

  # Make the launcher executable
  chmod +x "$SCRIPT_PATH"

  # Create the app wrapper
  osacompile -o "$APPLICATIONS_DIR/$name.app" -e "do shell script \"$SCRIPT_PATH\""

  # Add icon if specified
  if [[ -f "$icon" ]]; then
    cp "$icon" "$APPLICATIONS_DIR/$name.app/Contents/Resources/applet.icns"
    touch "$APPLICATIONS_DIR/$name.app"
  fi

  echo "Generated SSB for $name at $APPLICATIONS_DIR/$name.app"
done

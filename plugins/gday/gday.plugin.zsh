# gday plugin for oh-my-zsh

############    ██████╗ ██████╗  █████╗ ██╗   ██╗ ANSI Shadow
############   ██╔════╝ ██╔══██╗██╔══██╗╚██╗ ██╔╝
############   ██║  ███╗██║  ██║███████║ ╚████╔╝
############   ██║   ██║██║  ██║██╔══██║  ╚██╔╝
############   ╚██████╔╝██████╔╝██║  ██║   ██║
############    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝
############    TODO: extend lines in 30m increments, by duration
############    ╚═════╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝


########################################
# ChatGPT Pseudo-code
## [x] Header Creation: Generates a header for the output, including the current date and week number (for Mondays).
#
## [x] Table Headers: Prepares headers for the table that will display the calendar events.
#
## [x] Fetching Calendar Data: Uses gcalcli to fetch today's agenda from Google Calendar. The --details length flag is used to include the duration of each event.
#
## [x] Emoji Mapping: Defines a map of emojis for different times of the day. This is used to add a visual cue (emoji) to each event based on its start time.
#
## [-] Processing Calendar Output: The main part of the script processes the output from gcalcli. It involves several steps:
#
## [x] Removing ANSI color codes for plain text processing.
## [x] Parsing each line to extract the time, duration, and description of events.
## [x] Adding an emoji to the event if it doesn't start with one.
## [x] Converting the event duration from hours and minutes to a total in minutes.
## [x] Storing the processed information for each event.
## [x] Expanding Events Longer than 30 Minutes: For events longer than 30 minutes, the script splits them into multiple 30-minute blocks. It uses a custom function add_pomodoro to increment the time by 30 minutes for each block.
#
## [-] Handling Pomodoros and Event Conflicts: The script aims to remove pomodoro (🍅) events that conflict with longer events. This step seems to need refinement based on the issues you're experiencing.
#
## [x] Final Output Assembly: Constructs the final output table with the processed event data.
## ------------

## # Gday is a script to integrate my gCal with my daily notes. To help organize my time, the day should be broken into pomodoros wheverer I don't have existing appointments

## As JPB
## I want to connect my gCal to my daily notes
## Because I prefer to work in plaintext and markdown

## When I run gday
## Then all my gcal appointments should come in
## And any appointments longer than a pomodoro should be broken into 30m chunks
## And any appointments without an emoji should be assigned one based on their start time
## And their emoji should be duplicated for each chunk, ie the first Most Important Thing should start with 👑 and the second with 👑👑, etc
## And any unscheduled time should be broken into pomodoros
## And any pomodoros that conflict with other events should be removed

## ## Pseudo-code
## - Create Table Headers and define clock Emoji Map
## - Fetch Calendar Data from Google Calendar
## - Remove ANSI color codes from Cal data
## - extract time, duration, and description of events from each line of Cal data
## - Add clock emoji to Cal data lines lacking emoji
## - Expand Events Longer than 30 Minutes into multiple lines, 30m each
## - Remove Pomodoro lines that conflict with other events
## - Render the final markdown table
#

########################################
########################################
########################################
########################################


# Helper function to show banner
_gday_show_banner() {
  # Use semantic versioning: major.minor.patch. Human will bump the minor, Agents should bump the patch when we update the software.
  local GDAY_BANNER="
    🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞
    🌞🌞🌞    gday Version 3.10.0    🌞🌞🌞
    🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞


"
  echo -e "$GDAY_BANNER"
}

# Helper function to show only the "Later Today" section
_gday_later_today_section() {
  _gday_show_banner

  local config_file="$HOME/.config/gday/config.yml"
  if [[ ! -f "$config_file" ]]; then
    echo "Error: Configuration file not found at $config_file"
    return 1
  fi
  
  # Load filtered appointments from YAML
  local -a filtered_appointments_array
  local in_filtered_appointments=false
  
  while IFS= read -r line; do
    if [[ "$line" =~ ^filtered_appointments: ]]; then
      in_filtered_appointments=true
      filtered_appointments_array=()
    elif [[ $in_filtered_appointments == true && "$line" =~ ^[[:space:]]*-[[:space:]]*(.*) ]]; then
      local appointment=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/^"//' | sed 's/"$//')
      filtered_appointments_array+=("$appointment")
    elif [[ "$line" =~ ^[[:alpha:]]+: ]] && [[ $in_filtered_appointments == true ]]; then
      # New section started, stop processing filtered appointments
      break
    fi
  done < "$config_file"
  
  # For the later command, we need to generate the full schedule and then filter it
  # This is a simplified version that reuses the main gday logic
  local date_arg="today"
  local display_date=$(date "+%m/%d - %A")
  local week_number=$(date "+%V")
  
  # Build the calendar arguments string
  local calendar_args=""
  for cal in "${GCAL_CALENDARS[@]}"; do
    calendar_args="${calendar_args}--cal \"$cal\" "
  done
  
  local gcalcli_cmd="gcalcli $calendar_args agenda \"1am $date_arg\" \"11pm $date_arg\" --nocolor --no-military --details length"
  local calendar_data=$(eval "$gcalcli_cmd")
  local calendar_data_no_color=$(echo "$calendar_data" | sed 's/\x1b\[[0-9;]*m//g')
  calendar_data_no_color=$(echo "$calendar_data_no_color" | sed 's/|/—/g')
  
  # Process the calendar data exactly like the main function does
  local body=""
  local lines=()
  local time_count=()
  local prev_time=""
  local prev_item=""
  
  # Setup emoji map
  typeset -A emoji_map=(
    [800]="🕗" [830]="🕣" [900]="🕘" [930]="🕤"
    [1000]="🕙" [1030]="🕥" [1100]="🕚" [1130]="🕦"
    [1200]="🕛" [1230]="🕧" [100]="🕐" [130]="🕜"
    [200]="🕑" [230]="🕝" [300]="🕒" [330]="🕞"
    [400]="🕓" [430]="🕟" [500]="🕔" [530]="🕠"
    [600]="🕕" [630]="🕡" [700]="🕖" [730]="🕢"
  )
  
  # Process calendar data (simplified version of main logic)
  local target_day=$(date "+%a")
  local target_month=$(date "+%b")
  local target_date=$(date "+%d")
  local day_format="$target_day $target_month $target_date"
  
  local all_day_events=()
  
  while IFS= read -r line; do
    line=$(echo "$line" | sed 's/^[ \t]*//') # trim whitespace
    
    # Function to add a pomodoro (30 minutes) to a given time
    add_pomodoro() {
      local time=$1
      local new_time=$(date -j -v+30M -f "%I:%M%p" "$time" +"%I:%M%p")
      echo $new_time | sed 's/^0//' | tr '[:upper:]' '[:lower:]'
    }
    
    # Process time-based events like main function
    if [[ $line =~ ^[0-9]{1,2}:[0-9]{2}[apm]{2} ]]; then
      local time=$(echo "$line" | awk '{print $1}')
      local item=$(echo "$line" | awk '{$1=""; print substr($0,2)}')
      
      # Get duration from next line
      IFS= read -r next_line
      local duration_raw=$(echo "$next_line" | awk '/Length:/ {print $2}')
      local hours=$(echo "$duration_raw" | cut -d ':' -f 1)
      local minutes=$(echo "$duration_raw" | cut -d ':' -f 2)
      local total_minutes=$((hours * 60 + minutes))
      
      # Handle different event lengths
      if [[ $total_minutes -eq 1440 || ($time == "12:00am" && $total_minutes -gt 720) ]]; then
        if [[ ! $item =~ ^Length: ]]; then
          all_day_events+=("all-day|📅 $item (All-day)")
        fi
      elif [[ $total_minutes -eq 15 ]]; then
        if [[ $time =~ :15([ap]m) ]]; then
          time=$(echo "$time" | sed 's/:15/:00/')
          item="$item - $(echo "$line" | awk '{print $1}')"
        elif [[ $time =~ :45([ap]m) ]]; then
          time=$(echo "$time" | sed 's/:45/:30/')
          item="$item - $(echo "$line" | awk '{print $1}')"
        fi
        new_line="$time|$item"
        lines+=("$new_line")
      else
        local blocks=$((total_minutes / 30))
        if [[ $blocks -eq 0 ]]; then
          blocks=1
        fi
        
        for ((i=0; i<blocks; i++)); do
          new_line="$time|$item"
          if [[ "$item" != "🍅" || "$time" != "$prev_time" ]]; then
            lines+=("$new_line")
          fi
          prev_time="$time"
          time=$(add_pomodoro "$time")
        done
      fi
    fi
  done <<< "$calendar_data_no_color"
  
  # Add all-day events to the beginning
  lines=("${all_day_events[@]}" "${lines[@]}")
  
  # Generate the body table
  local body=""
  for line in "${lines[@]}"; do
    IFS='|' read -r time item <<< "$line"
    local time_number=$(echo "$time" | tr -d '[:alpha:]' | tr -d ':')
    
    if ! [[ $item =~ ^[^[:alnum:]] ]]; then
      local emoji=${emoji_map[$time_number]}
      item="${emoji} $item"
    fi
    
    local formatted_time="${time}       "
    formatted_time="${formatted_time:0:8}"
    local formatted_item="${item}                                                                                            "
    formatted_item="${formatted_item:0:88}"
    
    body="${body}| ${formatted_time} | ${formatted_item} |"$'\n'
  done
  
  # Join filtered appointments with pipe delimiter
  local filtered_appointments_joined=""
  for appt in "${filtered_appointments_array[@]}"; do
    if [[ -z "$filtered_appointments_joined" ]]; then
      filtered_appointments_joined="$appt"
    else
      filtered_appointments_joined="$filtered_appointments_joined|$appt"
    fi
  done
  
  echo $body | generate_later_today_h2s "$filtered_appointments_joined"
}

# Helper function to show filtered appointments
_gday_show_filtered_appointments() {
  _gday_show_banner

  local config_file="$HOME/.config/gday/config.yml"
  if [[ ! -f "$config_file" ]]; then
    echo "Error: Configuration file not found at $config_file"
    return 1
  fi
  
  echo "## Filtered Appointments"
  echo "The following appointments are excluded from 'Later Today' section:"
  echo ""
  
  local in_filtered_appointments=false
  
  while IFS= read -r line; do
    if [[ "$line" =~ ^filtered_appointments: ]]; then
      in_filtered_appointments=true
    elif [[ $in_filtered_appointments == true && "$line" =~ ^[[:space:]]*-[[:space:]]*(.*) ]]; then
      local appointment=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/^"//' | sed 's/"$//')
      echo "- $appointment"
    elif [[ "$line" =~ ^[[:alpha:]]+: ]] && [[ $in_filtered_appointments == true ]]; then
      # New section started, stop processing filtered appointments
      break
    fi
  done < "$config_file"
}

# Helper function to show help
_gday_show_help() {
  _gday_show_banner
  
  echo "gday - Personal calendar and task management tool"
  echo ""
  echo "USAGE:"
  echo "  gday [COMMAND|DATE]"
  echo ""
  echo "COMMANDS:"
  echo "  auth              Re-authenticate with Google Calendar"
  echo "  later             Show only the 'Later Today' section"
  echo "  filtered          Show the list of filtered appointments"
  echo "  help, --help      Show this help message"
  echo ""
  echo "DATE OPTIONS:"
  echo "  (no args)         Show today's schedule (default)"
  echo "  yesterday, yday   Show yesterday's schedule"
  echo "  monday            Show most recent Monday's schedule"
  echo "  tuesday           Show most recent Tuesday's schedule"
  echo "  wednesday         Show most recent Wednesday's schedule"
  echo "  thursday          Show most recent Thursday's schedule"
  echo "  friday            Show most recent Friday's schedule"
  echo "  saturday          Show most recent Saturday's schedule"
  echo "  sunday            Show most recent Sunday's schedule"
  echo ""
  echo "EXAMPLES:"
  echo "  gday              Show today's full schedule"
  echo "  gday yesterday    Show yesterday's schedule"
  echo "  gday friday       Show last Friday's schedule"
  echo "  gday later        Show only appointments for later today"
  echo "  gday filtered     Show which appointments are filtered out"
  echo ""
  echo "VERSION: 3.10.0"
}

# Helper function to extract filtered tasks
generate_later_today_h2s() {
  local filtered_appointments_param="$1"
  awk -v appointments="$filtered_appointments_param" '
    BEGIN {
      print "## Later Today..."
      print "```"
      split(appointments, appts, "|")
    }
    function normalize(str) {
      gsub(/[^a-zA-Z0-9 ]/, "", str)
      gsub(/^ +| +$/, "", str)  # Trim leading/trailing whitespace
      gsub(/ +/, " ", str)      # Normalize spaces
      return tolower(str)       # Case-insensitive comparison
    }
    /^\| [0-9]/ {
      line = $0
      sub(/^\|[^|]+\| /, "## ", line)  # Remove everything up to the title
      sub(/ \|$/, "", line)  # Remove trailing pipe

      # Extract appointment title for exact matching
      title = line
      sub(/^## /, "", title)  # Remove the ## prefix

      # Check against our list of filtered appointments with exact matching
      skip = 0
      for (i in appts) {
        if (normalize(title) == normalize(appts[i])) {
          skip = 1
          break
        }
      }

      if (!skip) {
        norm = normalize(line)
        if (!seen[norm]++) {
          print line
        }
      }
    }
    END {
      print "## Been Reading..."
      print "```"
      print ""
    }
  '
}

# Add calendar configuration
GCAL_CALENDARS=(
  "JPB-DW"
  "Pomo"
  "JPB Private"
  "Berger Appointments"
  "Wildcards"
)

# Helper function to validate calendars
validate_calendars() {
  # Get available calendars - extract the entire calendar name, preserving spaces
  local available_calendars=$(gcalcli list --nocolor | awk 'NR > 1 {
    # Skip separator lines that contain only dashes/hyphens
    if ($0 ~ /^[- ]+$/) next;
    # Remove the first two columns (Owner and Access)
    $1=""; $2="";
    # Print the rest of the line (the calendar name)
    sub(/^[ \t]+/, "");
    print
  }')
  local missing_calendars=()
  local found=0

  echo "Checking configured calendars..."

  # Print table header
  echo "\n| Included? | Available Calendars              |"
  echo "|-----------|----------------------------------|"

  # Process each available calendar
  while IFS= read -r cal; do
    # Skip empty lines or lines containing only dashes/hyphens
    if [[ -n "$cal" && ! "$cal" =~ ^[-]+$ ]]; then
      # Check if calendar is in configured list
      local is_configured=false
      local is_accessible=false

      for config_cal in "${GCAL_CALENDARS[@]}"; do
        if [[ "$cal" == "$config_cal" ]]; then
          is_configured=true
          # Verify we can actually use it with gcalcli
          if gcalcli --cal "$cal" agenda "today" "today" --nocolor --no-military >/dev/null 2>&1; then
            is_accessible=true
            ((found++))
          else
            missing_calendars+=("$cal")
          fi
          break
        fi
      done

      # Format the table row
      local cal_status="🔲"
      if $is_configured && $is_accessible; then
        cal_status="✅"
      fi

      # Add padding to make calendar name fit nicely
      local padded_cal="$cal                                   "
      padded_cal="${padded_cal:0:34}"

      # Format the status with consistent spacing - center the emoji in 9 chars
      local formatted_status="    $cal_status    "
      formatted_status="${formatted_status:0:9}"

      echo "| $formatted_status | $padded_cal |"
    fi
  done <<< "$available_calendars"

  echo "\nValidation results:"
  if [[ ${#missing_calendars[@]} -gt 0 ]]; then
    echo "⚠️  The following calendars are configured but not usable:"
    printf "   - %s\n" "${missing_calendars[@]}"
    if [[ $found -eq 0 ]]; then
      echo "❌ No configured calendars were found. Exiting."
      return 1
    fi
  else
    echo "✅ All configured calendars found!"
  fi
  return 0
}


function gday() {

  case "$1" in
    auth)
      echo "Removing gcalcli OAuth token..."
      touch ~/.gcalcli_oauth
      rm ~/.gcalcli_oauth
      echo "running \`gcalcli agenda\`. If this fails, try \`gcalcli init\` to force the auth flow"
      gcalcli init
      return
      ;;
    later)
      # Only show the "Later Today" section
      _gday_later_today_section
      return
      ;;
    filtered)
      # Show filtered appointments from config
      _gday_show_filtered_appointments
      return
      ;;
    --help|help)
      _gday_show_help
      return
      ;;
    prev|yesterday|yday|then)
      date_arg="yesterday"
      display_date=$(date -v -1d "+%m/%d - %A")
      week_number=$(date -v -1d "+%V")
      ;;
    monday|tuesday|wednesday|thursday|friday|saturday|sunday)
      # Convert input to lowercase and capitalize first letter for display
      day_lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
      day_display=$(echo "${day_lower^}")

      # Find the most recent occurrence of the specified day
      # On macOS, we use date -v to adjust the date
      current_day=$(date "+%A" | tr '[:upper:]' '[:lower:]')

      if [[ "$current_day" == "$day_lower" ]]; then
        # If today is the requested day, just use today
        date_arg="today"
        display_date=$(date "+%m/%d - %A")
        week_number=$(date "+%V")
      else
        # Calculate days ago - first get day numbers (0=Sunday, 6=Saturday)
        current_day_num=$(date "+%w")
        target_day_num=0

        case "$day_lower" in
          monday) target_day_num=1 ;;
          tuesday) target_day_num=2 ;;
          wednesday) target_day_num=3 ;;
          thursday) target_day_num=4 ;;
          friday) target_day_num=5 ;;
          saturday) target_day_num=6 ;;
          sunday) target_day_num=0 ;;
        esac

        # Calculate days to go back
        days_ago=$(( ($current_day_num - $target_day_num + 7) % 7 ))
        if [[ $days_ago -eq 0 ]]; then
          days_ago=7  # If calculated as 0, we want the previous week
        fi

        # Set the date argument
        date_arg="$days_ago days ago"
        display_date=$(date -v "-${days_ago}d" "+%m/%d - %A")
        week_number=$(date -v "-${days_ago}d" "+%V")
      fi
      ;;
    *)
      date_arg="today"
      display_date=$(date "+%m/%d - %A")
      week_number=$(date "+%V")
      ;;
  esac

  # Calendar and task display configuration
  local title="## 🪢 Todo Today"
  local table_header="| Time    | Item                                                                                   |"
  local table_separator="|---------|----------------------------------------------------------------------------------------|"
  local kicker="\n******* DO WHATEVER THE SCHEDULE TELLS ME. AND ONLY THAT.**********\n\n\n"


  # Validate calendars first
  if ! validate_calendars; then
    return 1
  fi

  # Load configuration from YAML
  local config_file="$HOME/.config/gday/config.yml"
  if [[ ! -f "$config_file" ]]; then
    echo "Warning: gday configuration file not found at $config_file"
    echo "Create ~/.config/gday/config.yml to customize prompts"
    return 1
  fi
  
  # Parse new YAML structure
  typeset -A prompt_groups_freq
  typeset -A prompt_groups_content
  local -a filtered_appointments_array
  local current_group=""
  local current_frequency=""
  local in_content=false
  local in_filtered_appointments=false
  
  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*name:[[:space:]]*\"(.*)\" ]]; then
      # Start of new prompt group
      current_group="${match[1]}"
      in_content=false
      in_filtered_appointments=false
    elif [[ "$line" =~ ^[[:space:]]*frequency:[[:space:]]*(.*) ]]; then
      # Frequency line
      current_frequency="${match[1]}"
      # Remove comments
      current_frequency=$(echo "$current_frequency" | sed 's/#.*//' | sed 's/[[:space:]]*$//')
      prompt_groups_freq[$current_group]="$current_frequency"
    elif [[ "$line" =~ ^[[:space:]]*content: ]]; then
      # Start of content section
      in_content=true
      in_filtered_appointments=false
      prompt_groups_content[$current_group]=""
    elif [[ "$line" =~ ^filtered_appointments: ]]; then
      # Start of filtered appointments section
      in_filtered_appointments=true
      in_content=false
      filtered_appointments_array=()
    elif [[ $in_content == true && "$line" =~ ^[[:space:]]*-[[:space:]]*(.*) ]]; then
      # Content line
      local prompt=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/^"//' | sed 's/"$//')
      local current_content="${prompt_groups_content[$current_group]}"
      if [[ -z "$current_content" ]]; then
        prompt_groups_content[$current_group]="$prompt"
      else
        prompt_groups_content[$current_group]="$current_content|$prompt"
      fi
    elif [[ $in_filtered_appointments == true && "$line" =~ ^[[:space:]]*-[[:space:]]*(.*) ]]; then
      # Filtered appointment line
      local appointment=$(echo "$line" | sed 's/^[[:space:]]*-[[:space:]]*//' | sed 's/^"//' | sed 's/"$//')
      filtered_appointments_array+=("$appointment")
    fi
  done < "$config_file"

  _gday_show_banner

  ##### Setup
  typeset -A emoji_map=(
    [800]="🕗" [830]="🕣" [900]="🕘" [930]="🕤"
    [1000]="🕙" [1030]="🕥" [1100]="🕚" [1130]="🕦"
    [1200]="🕛" [1230]="🕧" [100]="🕐" [130]="🕜"
    [200]="🕑" [230]="🕝" [300]="🕒" [330]="🕞"
    [400]="🕓" [430]="🕟" [500]="🕔" [530]="🕠"
    [600]="🕕" [630]="🕡" [700]="🕖" [730]="🕢"
  )


  # Build the calendar arguments string
  local calendar_args=""
  for cal in "${GCAL_CALENDARS[@]}"; do
    calendar_args="${calendar_args}--cal \"$cal\" "
  done

  # Calculate target date for filtering events
  local target_day=""
  local target_month=""
  local target_date=""

  if [[ "$date_arg" == "today" ]]; then
    target_day=$(date "+%a")     # Day of week (e.g., "Thu")
    target_month=$(date "+%b")   # Month (e.g., "May")
    target_date=$(date "+%d")    # Day number (e.g., "08")
  elif [[ "$date_arg" == "yesterday" ]]; then
    target_day=$(date -v -1d "+%a")
    target_month=$(date -v -1d "+%b")
    target_date=$(date -v -1d "+%d")
  elif [[ "$date_arg" =~ ([0-9]+)\ days\ ago ]]; then
    local days_ago="${match[1]}"
    target_day=$(date -v "-${days_ago}d" "+%a")
    target_month=$(date -v "-${days_ago}d" "+%b")
    target_date=$(date -v "-${days_ago}d" "+%d")
  fi

  # Create day format for comparison
  local day_format="$target_day $target_month $target_date"

  # Use pipx-installed gcalcli with wider date range to capture multi-day events
  local gcalcli_cmd="gcalcli $calendar_args agenda \"1am $date_arg\" \"11pm $date_arg\" --nocolor --no-military --details length"

  echo "~~~ running this gcalcli command for $date_arg ~~~\n\n    $gcalcli_cmd\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"

  local calendar_data=$(eval "$gcalcli_cmd")
  local calendar_data_no_color=$(echo "$calendar_data" | sed 's/\x1b\[[0-9;]*m//g')

  ###### convert pipe characters to an em-dash (bc escaping pipes is hard)
  calendar_data_no_color=$(echo "$calendar_data_no_color" | sed 's/|/—/g')

  local body=""
  local lines=()
  local time_count=()
  local prev_time=""
  local prev_item=""

##### Process the calendar data
local all_day_events=()

while IFS= read -r line; do
  line=$(echo "$line" | sed 's/^[ \t]*//') # trim whitespace

  # Function to add a pomodoro (30 minutes) to a given time
  add_pomodoro() {
    local time=$1
    local new_time=$(date -j -v+30M -f "%I:%M%p" "$time" +"%I:%M%p")
    echo $new_time | sed 's/^0//' | tr '[:upper:]' '[:lower:]'
  }

  # Check for all-day events in various formats

  # First, directly check if the line contains asterisks (common all-day event marker)
  if [[ $line == *"******"* ]]; then
    local item=$(echo "$line" | sed -E 's/^[A-Za-z]+ [A-Za-z]+ [0-9]+[[:space:]]+\*+[[:space:]]+//')
    all_day_events+=("all-day|📅 $item (All-day)")
    continue
  fi

  # Check if this line has our target date format (e.g., "Wed May 07")
  # After a date line, there might be all-day events without time stamps
  if [[ $line == "$target_day $target_month $target_date"* || $line == *"$target_month $target_date"* ]]; then
    # Debug output
    # echo "DEBUG: Found matching date line: $line" >&2

    # Keep reading subsequent lines until we find a time-based event
    while IFS= read -r next_line; do
      next_line=$(echo "$next_line" | sed 's/^[ \t]*//') # trim whitespace

      # Debug output
      # echo "DEBUG: Reading subsequent line: $next_line" >&2

      # If we find a line with asterisks, it's an all-day event
      if [[ $next_line == *"******"* ]]; then
        local item=$(echo "$next_line" | sed 's/^[[:space:]]*\*\+[[:space:]]*//')
        all_day_events+=("all-day|📅 $item (All-day)")
        continue
      fi

      # If we find a line without a time stamp, it could be an all-day event
      if [[ ! $next_line =~ ^[0-9]{1,2}:[0-9]{2}[apm]{2} && -n "$next_line" && $next_line != *"No Events"* ]]; then
        # Check if it's not a date line for a different day
        if [[ ! $next_line =~ ^[A-Za-z]{3}\ [A-Za-z]{3}\ [0-9]{2} ]]; then
          # Skip "Length:" lines as they're just duration information, not events
          if [[ ! $next_line =~ ^Length: ]]; then
            all_day_events+=("all-day|📅 $next_line (All-day)")
          fi
        else
          # It's a date line for a different day, stop processing
          line="$next_line"
          break
        fi
      else
        # We found a time-based event or empty line, so we're done with all-day events
        line="$next_line"
        break
      fi
    done
  fi

  if [[ $line =~ ^[0-9]{1,2}:[0-9]{2}[apm]{2} ]]; then # if line starts with time
    local time=$(echo "$line" | awk '{print $1}') # extract vars
    local item=$(echo "$line" | awk '{$1=""; print substr($0,2)}')
    local original_time=$time

    # Get the next line for duration
    IFS= read -r next_line
    local duration_raw=$(echo "$next_line" | awk '/Length:/ {print $2}')
    local hours=$(echo "$duration_raw" | cut -d ':' -f 1)
    local minutes=$(echo "$duration_raw" | cut -d ':' -f 2)
    local total_minutes=$((hours * 60 + minutes))

    # Check for all-day events (typically 24 hours)
    if [[ $total_minutes -eq 1440 || ($time == "12:00am" && $total_minutes -gt 720) ]]; then
      # Exclude "Length:" entries but include all other all-day events
      if [[ ! $item =~ ^Length: ]]; then
        all_day_events+=("all-day|📅 $item (All-day)")
      else
        # Handle as regular events by splitting into 30-minute blocks
        local blocks=$((total_minutes / 30))
        if [[ $blocks -eq 0 ]]; then
          blocks=1
        fi

        for ((i=0; i<blocks && i<48; i++)); do  # Cap at 48 blocks (24 hours)
          new_line="$time|$item"
          if [[ "$item" != "🍅" || "$time" != "$prev_time" ]]; then
            lines+=("$new_line")
          fi
          prev_time="$time"
          time=$(add_pomodoro "$time")
        done
      fi
    # Handle 15-minute appointments
    elif [[ $total_minutes -eq 15 ]]; then
      # For appointments ending in :15, snap to previous :00
      if [[ $time =~ :15([ap]m) ]]; then
        time=$(echo "$time" | sed 's/:15/:00/')
        item="$item - $original_time"
      # For appointments ending in :45, snap to previous :30
      elif [[ $time =~ :45([ap]m) ]]; then
        time=$(echo "$time" | sed 's/:45/:30/')
        item="$item - $original_time"
      fi
      new_line="$time|$item"
      lines+=("$new_line")
    else
      # For longer events, split into 30-minute blocks
      local blocks=$((total_minutes / 30))
      if [[ $blocks -eq 0 ]]; then
        blocks=1
      fi

      for ((i=0; i<blocks; i++)); do
        new_line="$time|$item"
        if [[ "$item" != "🍅" || "$time" != "$prev_time" ]]; then
          lines+=("$new_line")
        fi
        prev_time="$time"
        time=$(add_pomodoro "$time")
      done
    fi
  fi
done <<< "$calendar_data_no_color"

# Filter out any "Length:" entries from all-day events
local filtered_all_day_events=()
for event in "${all_day_events[@]}"; do
  if [[ ! $event =~ Length: ]]; then
    filtered_all_day_events+=("$event")
  fi
done

# Add filtered all-day events to the beginning of the lines array
lines=("${filtered_all_day_events[@]}" "${lines[@]}")

##### Add emoji to items lacking emoji and construct the final table
for line in "${lines[@]}"; do
  IFS='|' read -r time item <<< "$line"
  local time_number=$(echo "$time" | tr -d '[:alpha:]' | tr -d ':')

  if ! [[ $item =~ ^[^[:alnum:]] ]]; then # if item lacks emoji
    local emoji=${emoji_map[$time_number]} # then add emoji
    item="${emoji} $item"
  fi

  # Format time with consistent spacing
  local formatted_time="${time}       "
  formatted_time="${formatted_time:0:8}"

  # Pad item with spaces for consistent column width
  local formatted_item="${item}                                                                                            "
  formatted_item="${formatted_item:0:88}"

  body="${body}| ${formatted_time} | ${formatted_item} |"$'\n'
done

  local dateline="# $display_date"
  if [[ $display_date == *"Monday"* ]]; then
    dateline="# $display_date - 📆 Week $week_number"
  fi

  echo -e "${dateline}\n\n"
  
  # Process each prompt group based on frequency
  for group in "${(k)prompt_groups_freq[@]}"; do
    local frequency="${prompt_groups_freq[$group]}"
    local content="${prompt_groups_content[$group]}"
    # Split content by | delimiter
    IFS='|' read -A prompts <<< "$content"
    
    if [[ "$frequency" == "daily" ]]; then
      # Show all prompts from this group
      for prompt in "${prompts[@]}"; do
        echo -e "${prompt}\n\n"
      done
    elif [[ "$frequency" =~ "rotating\(([0-9]+)\)" ]]; then
      # Rotating frequency - show N prompts with fair distribution
      local count="${match[1]}"
      local day_of_year=$(date +%j)
      local total_prompts=${#prompts[@]}
      # Calculate starting index for today
      local start_index=$(( (day_of_year * count) % total_prompts ))
      
      # Show the specified number of prompts
      for ((i = 0; i < count && i < total_prompts; i++)); do
        local index=$(( (start_index + i) % total_prompts ))
        echo -e "${prompts[$index]}\n\n"
      done
    elif [[ "$frequency" =~ "random\(([0-9]+)\)" ]]; then
      # Random frequency - show N random prompts
      local count="${match[1]}"
      local selected=()
      local available=("${prompts[@]}")
      
      # Seed random with date for consistency within the day
      RANDOM=$(date +%j)
      
      # Pick random prompts without replacement
      for ((i = 0; i < count && ${#available[@]} > 0; i++)); do
        local rand_index=$((RANDOM % ${#available[@]}))
        echo -e "${available[$rand_index]}\n\n"
        # Remove selected prompt from available list
        available=("${available[@]:0:$rand_index}" "${available[@]:$((rand_index + 1))}")
      done
    fi
  done
  echo -e "${title}\n${table_header}\n${table_separator}\n${body}\n\n"
  echo -e "${kicker}"

  # Show git activity report
  ~/workspace/dot-rot/bin/yday-semantic

  # Now show the Later Today section
  # Join filtered appointments with pipe delimiter
  local filtered_appointments_joined=""
  for appt in "${filtered_appointments_array[@]}"; do
    if [[ -z "$filtered_appointments_joined" ]]; then
      filtered_appointments_joined="$appt"
    else
      filtered_appointments_joined="$filtered_appointments_joined|$appt"
    fi
  done
  
  echo $body | generate_later_today_h2s "$filtered_appointments_joined"
}

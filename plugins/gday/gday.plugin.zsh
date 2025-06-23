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


# Helper function to extract filtered tasks
generate_later_today_h2s() {
  awk -v appointments="${FILTERED_APPOINTMENTS[*]}" '
    BEGIN {
      print "## Later Today..."
      print "```"
      split(appointments, appts, " ")
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
    # Remove the first two columns (Owner and Access)
    $1=""; $2="";
    # Print the rest of the line (the calendar name)
    sub(/^[ \t]+/, "");
    print
  }')
  local missing_calendars=()
  local found=0

  echo "Checking configured calendars..."
  echo "\nAvailable calendars:"
  echo "$available_calendars" # | sed 's/^/   - /'

  echo "\nConfigured calendars:"
  for cal in "${GCAL_CALENDARS[@]}"; do
    # Check if calendar exists EXACTLY in available list (not as substring)
    if echo "$available_calendars" | grep -Fx "$cal" > /dev/null; then
      # Then verify we can actually use it with gcalcli
      if gcalcli --cal "$cal" agenda "today" "today" --nocolor --no-military >/dev/null 2>&1; then
        echo "   - ✅ $cal"
        ((found++))
      else
        echo "   - ❌ $cal (exists but gcalcli cannot access it)"
        missing_calendars+=("$cal")
      fi
    else
      echo "   - ❌ $cal (not found in available calendars)"
      missing_calendars+=("$cal")
    fi
  done

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

# Filtered appointments
FILTERED_APPOINTMENTS=(
  " Elias Allergy Shots"
  "Somatic Call with Jenna"
  "☀️❤️😘 after maria takes Esz: JPB / KW standup"
  "🍅"
  "🍜 Lunch"
  "🏋️ JPB workout / 📔 morning pages"
  "📓 Boys do homework while adult cooks"
  "🤼‍♀️ Elias tap outs"
)

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

  # Banner and version
  local GDAY_BANNER="
    🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞
    🌞🌞🌞    gday Version 3.5.0    🌞🌞🌞
    🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞 \n\n"

  # Prompts and sections
  local hearts_desire_EOB="## 🧞‍♂️ What is top-of-mind for 🐲? What do the want rn?"
  local hearts_desire_EAB="## 🧞‍♂️ What is top-of-mind for 🦅🦁? What do the want rn?"
  local hearts_desire_EMB="## 🧞‍♂️ What is top-of-mind for 🦄? What do the want rn?"
  local hearts_desire_ELB="## 🧞‍♂️ What is top-of-mind for 🐴🪽? What do the want rn?"
  local hearts_desire_KWB="## 🧞‍♂️ What is top-of-mind for KWB? What do the want rn?"
  local hearts_desire_JPB="## 🧞‍♂️ What is top-of-mind for JPB? What do the want rn?"
  local spoons="## 🥄 What did you spend spoons on yesterday?"
  local yday="## 🚢 What did you ship yesterday?"
  local wild="## 🃏 What Wildcards are in play today?"
  local braindump="## 🫃 What's on your mind rn? 🐸🧹👑 \n\n\n\n\n--- "
  local frogs="\n- 1st 🐸 I'll eat:\n- 2nd 🐸 I'll eat:\n- 3rd 🐸 I'll eat:\n\n"
  local title="## 🪢 Todo Today"
  local table_header="| Time    | Item |"
  local table_separator="|---------|------|"
  local kicker="\n******* DO WHATEVER THE SCHEDULE TELLS ME. AND ONLY THAT.**********\n\n\n"


  # Validate calendars first
  if ! validate_calendars; then
    return 1
  fi

  echo -e "$GDAY_BANNER"

  ##### Setup
  declare -A emoji_map=(
    [800]="🕗" [830]="🕣" [900]="🕘" [930]="🕤"
    [1000]="🕙" [1030]="🕥" [1100]="🕚" [1130]="🕦"
    [1200]="🕛" [1230]="🕧" [100]="🕐" [130]="🕜"
    [200]="🕑" [230]="🕝" [300]="🕒" [330]="🕞"
    [400]="🕓" [430]="🕟" [500]="🕔" [530]="🕠"
    [600]="🕕" [630]="🕡" [700]="🕖" [730]="🕢"
  )

  if [[ $display_date == *"Monday"* ]]; then
    h1+=" - 📆 Week $week_number"
  fi

  # Build the calendar arguments string
  local calendar_args=""
  for cal in "${GCAL_CALENDARS[@]}"; do
    calendar_args+="--cal \"$cal\" "
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
    local days_ago=${BASH_REMATCH[1]}
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
          # It's probably an all-day event
          all_day_events+=("all-day|📅 $next_line (All-day)")
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
      all_day_events+=("all-day|📅 $item (All-day)")
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

# Add all-day events to the beginning of the lines array
lines=("${all_day_events[@]}" "${lines[@]}")

##### Add emoji to items lacking emoji and construct the final table
for line in "${lines[@]}"; do
  IFS='|' read -r time item <<< "$line"
  local time_number=$(echo "$time" | tr -d '[:alpha:]' | tr -d ':')

  if ! [[ $item =~ ^[^[:alnum:]] ]]; then # if item lacks emoji
    local emoji=${emoji_map[$time_number]} # then add emoji
    item="${emoji} $item"
  fi

  body+="| ${time} | ${item} |"$'\n'
done

  local dateline="# $display_date"
  if [[ $display_date == *"Monday"* ]]; then
    dateline="# $display_date - 📆 Week $week_number"
  fi

  echo -e "${dateline}\n\n"
  echo -e "${hearts_desire_EOB}\n\n"
  echo -e "${hearts_desire_EAB}\n\n"
  echo -e "${hearts_desire_EMB}\n\n"
  echo -e "${hearts_desire_ELB}\n\n"
  echo -e "${hearts_desire_KWB}\n\n"
  echo -e "${hearts_desire_JPB}\n\n"
  echo -e "${spoons}\n\n\n\n"
  echo -e "${yday}\n\n\n\n"
  echo -e "${wild}\n\n\n\n"
  echo -e "${braindump}\n\n\n\n"
  echo -e "${title}\n${table_header}\n${table_separator}\n${body}\n\n"
  echo -e "${kicker}"
  echo $body | generate_later_today_h2s
}

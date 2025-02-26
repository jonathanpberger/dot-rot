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
      return str
    }
    /^\| [0-9]/ {
      line = $0
      sub(/^\|[^|]+\| /, "## ", line)
      gsub(/ \|$/, "", line)

      # Check against our list of filtered appointments
      skip = 0
      for (i in appts) {
        if (index(line, appts[i]) > 0) {
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
  "Berger"
)

# Helper function to validate calendars
validate_calendars() {
  # Get available calendars - extract just the Title column, one per line
  local available_calendars=$(gcalcli list --nocolor | awk 'NR > 1 {for (i=3; i<=NF; i++) printf $i " "; print ""}')
  local missing_calendars=()
  local found=0

  echo "Checking configured calendars..."
  echo "\nAvailable calendars:"
  echo "$available_calendars" | sed 's/^/   - /'

  echo "\nConfigured calendars:"
  for cal in "${GCAL_CALENDARS[@]}"; do
    # First check if calendar exists in available list
    if echo "$available_calendars" | tr -d '\n' | grep -wq "$cal"; then
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
  "🍜 Lunch"  # Lunch
  "📓 Boys do homework while adult cooks"
  "🍅"
)

function gday() {
  # Validate calendars first
  if ! validate_calendars; then
    return 1
  fi

  # Banner and version
  local GDAY_BANNER="
    🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞
    🌞🌞🌞    gday Version 3.0.3    🌞🌞🌞
    🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞 \n\n"

  # Prompts and sections
  local spoons="## 🥄 What did you spend spoons on yesterday?"
  local yday="## 🚢 What did you ship yesterday?"
  local wild="## 🃏 What Wildcards are in play today?"
  local braindump="## 🫃 What's on your mind rn? 🐸🧹👑 \n\n\n\n\n--- "
  local frogs="\n- 1st 🐸 I'll eat:\n- 2nd 🐸 I'll eat:\n- 3rd 🐸 I'll eat:\n\n"
  local title="## 🪢 Todo Today"
  local table_header="| Time    | Item |"
  local table_separator="|---------|------|"
  local kicker="\n******* DO WHATEVER THE SCHEDULE TELLS ME. AND ONLY THAT.**********\n\n\n"

  case "$1" in
    auth)
      echo "Removing gcalcli OAuth token and running agenda. If this fails, try `gcalcli init` to force the auth flow"
      rm ~/.gcalcli_oauth && gcalcli agenda
      return
      ;;
    prev|yesterday|yday|then)
      date_arg="yesterday"
      display_date=$(date -v -1d "+%m/%d - %A")
      week_number=$(date -v -1d "+%V")
      ;;
    *)
      date_arg="today"
      display_date=$(date "+%m/%d - %A")
      week_number=$(date "+%V")
      ;;
  esac

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

  # Use pipx-installed gcalcli
  local gcalcli_cmd="gcalcli $calendar_args agenda \"1am $date_arg\" \"11pm $date_arg\" --nocolor --no-military --details length"

  echo "~~~ running this gcalcli command ~~~\n\n    $gcalcli_cmd\n\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\n\n\n"

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
while IFS= read -r line; do
  line=$(echo "$line" | sed 's/^[ \t]*//') # trim whitespace

  # Function to add a pomodoro (30 minutes) to a given time
  add_pomodoro() {
    local time=$1
    local new_time=$(date -j -v+30M -f "%I:%M%p" "$time" +"%I:%M%p")
    echo $new_time | sed 's/^0//' | tr '[:upper:]' '[:lower:]'
  }

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

    # Handle 15-minute appointments
    if [[ $total_minutes -eq 15 ]]; then
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
  echo -e "${spoons}\n\n\n\n"
  echo -e "${yday}\n\n\n\n"
  echo -e "${wild}\n\n\n\n"
  echo -e "${braindump}\n\n\n\n"
  echo -e "${title}\n${table_header}\n${table_separator}\n${body}\n\n"
  echo -e "${kicker}"
  echo $body | generate_later_today_h2s
}




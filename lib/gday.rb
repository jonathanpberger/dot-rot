require 'open3'
require 'time'
require 'logger'

class Gday
  EMOJI_MAP = {
    '0830' => '🕤',  # 8:30
    '0900' => '🕒',  # 9:00
    '0930' => '🕤',  # 9:30
    '1000' => '🕙',  # 10:00
    '1030' => '🕥',  # 10:30
    '1100' => '🕚',  # 11:00
    '1130' => '🕦',  # 11:30
    '1200' => '🕛',  # 12:00
    '1230' => '🕧',  # 12:30
    '1300' => '🕐',  # 1:00
    '1330' => '🕜',  # 1:30
    '1400' => '🕑',  # 2:00
    '1430' => '🕝',  # 2:30
    '1500' => '🕒',  # 3:00
    '1530' => '🕞',  # 3:30
    '1600' => '🕓',  # 4:00
    '1630' => '🕟',  # 4:30
    '1700' => '🕔',  # 5:00
    '1730' => '🕠',  # 5:30
    '1800' => '🕕',  # 6:00
    '1830' => '🕡',  # 6:30
    '1900' => '🕖',  # 7:00
  }.freeze

  def self.parse_tsv(tsv_data)
    # Skip header
    lines = tsv_data.lines.drop(1)

    lines.map do |line|
      fields = line.strip.split(/\s+/, 5)
      {
        date: fields[0],
        time: fields[1],
        end_date: fields[2],
        end_time: fields[3],
        title: fields[4]
      }
    end
  end

  def self.align_to_pomodoros(events)
    events.map do |event|
      time = event[:time]
      minutes = time.split(":")[1].to_i

      # Round to nearest 30 minutes
      aligned_minutes = ((minutes + 15) / 30) * 30
      aligned_minutes = 0 if aligned_minutes == 60

      event.merge(time: sprintf("%02d:%02d", time.split(":")[0].to_i, aligned_minutes))
    end
  end

  def self.remove_duplicate_pomodoros(events)
    events.group_by { |e| e[:time] }.map do |time, time_events|
      if time_events.length > 1 && time_events.any? { |e| e[:title] == "🍅" }
        time_events.reject { |e| e[:title] == "🍅" }
      else
        time_events
      end
    end.flatten
  end

  def self.add_missing_emoji(events)
    events.map do |event|
      if event[:title].match?(/^[[:alnum:]]/) # If title starts with alphanumeric
        # Convert time to 24-hour format for lookup
        hour, minute = event[:time].split(":")
        hour = hour.to_i
        hour += 12 if hour < 12 && event[:time].include?('pm')
        time_key = sprintf("%02d%02d", hour, minute)

        emoji = EMOJI_MAP[time_key] || '⭐️'  # Default emoji if time not found
        event.merge(title: "#{emoji} #{event[:title]}")
      else
        event
      end
    end
  end

  def self.expand_long_events(events)
    events.flat_map do |event|
      start_time = Time.parse(event[:time])
      end_time = Time.parse(event[:end_time])
      duration_minutes = ((end_time - start_time) / 60).to_i

      if duration_minutes <= 30
        [event]
      else
        blocks = []
        current_time = start_time

        while current_time < end_time
          blocks << {
            time: current_time.strftime("%H:%M"),
            end_time: (current_time + 30*60).strftime("%H:%M"),
            title: event[:title],
            date: event[:date],
            end_date: event[:end_date]
          }
          current_time += 30*60  # Add 30 minutes
        end
        blocks
      end
    end
  end

  def self.to_markdown_table(tsv_data)
    return "| Time    | Item |\n|---------|------|" if tsv_data.lines.count <= 1

    events = parse_tsv(tsv_data)
    events = align_to_pomodoros(events)
    events = remove_duplicate_pomodoros(events)
    events = add_missing_emoji(events)
    events = expand_long_events(events)

    table = ["| Time    | Item |", "|---------|------|"]

    events.each do |event|
      hour, minute = event[:time].split(":")
      hour = hour.to_i
      meridian = hour >= 12 ? "pm" : "am"
      hour = hour % 12
      hour = 12 if hour == 0
      formatted_time = "#{hour}:#{minute}#{meridian}"

      table << "| #{formatted_time.ljust(8)} | #{event[:title]} |"
    end

    table.join("\n")
  end

  def self.run
    # Hard-coded gcalcli command for now
    command = 'gcalcli --cal "JPB-DW" --cal "Pomo" --cal "JPB Private" agenda "1am today" "11pm today" --nocolor --no-military --details length --nodeclined --tsv'
    calendar_data = `#{command}`

    # Print header
    puts "    🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞"
    puts "    🌞🌞🌞    gday RUBY Version 3.0.0    🌞🌞🌞"
    puts "    🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞 \n\n"

    puts "# #{Time.now.strftime('%m/%d - %A')}"
    puts "\n## 🪢 Todo Today"
    puts to_markdown_table(calendar_data)
  end
end

# Run if this file is being run directly (not required/imported)
Gday.run if __FILE__ == $0
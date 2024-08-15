class GDay
  puts "~~~~~~~~~~~ gday mate!"
  EMOJI_MAP = {
    800 => '🕗', 830 => '🕣', 900 => '🕘', 930 => '🕤', 1000 => '🕙', 1030 => '🕥', 1100 => '🕚', 1130 => '🕦', 1200 => '🕛', 1230 => '🕧', 1300 => '🕐', 1330 => '🕜', 1400 => '🕑', 1430 => '🕝', 1500 => '🕒', 1530 => '🕞', 1600 => '🕓', 1630 => '🕟', 1700 => '🕔', 1730 => '🕠', 1800 => '🕕', 1830 => '🕡', 1900 => '🕖', 1930 => '🕢'
  }

  TITLE = '## 🪢 Todo Today'
  TABLE_HEADER = '| Time    | Item |'
  TABLE_SEPARATOR = '|---------|------|'
  KICKER = "\n******* DO WHATEVER THE SCHEDULE TELLS ME. AND ONLY THAT.**********\n\n### Brain Dump (for 👑s)\n\n\n --- \n\n\n- 1st 🐸 I'll eat:\n- 2nd 🐸 I'll eat:\n- 3rd 🐸 I'll eat:\n\n"

  def initialize(calendar_data)
    @calendar_data = calendar_data
    @calendar_data_no_color = remove_ansi_codes(@calendar_data)
    process_calendar_data
  end

  def remove_ansi_codes(data)
    data.gsub(/\e\[[0-9;]*m/, '')
  end

  def add_pomodoro(start_time)
    time_obj = Time.parse(start_time)
    new_time_obj = time_obj + (30 * 60)
    new_time_obj.strftime('%I:%M%p').downcase.sub(/^0/, '')
  end

  def generate_header
    today = Date.today
    if today.wday == 1
      "# \\#{today.strftime('%m/%d')} - \\#{today.strftime('%A')} - 📆 Week \\#{today.cweek}"
    else
      "# \\#{today.strftime('%m/%d')} - \\#{today.strftime('%A')}"
    end
  end

  def generate_body
    @lines.map do |line|
      time, item = line.split('|')
      emoji = EMOJI_MAP[time.tr(':', '').to_i] || ''
      "| \\#{time} | \\#{emoji} \\#{item.strip} |\n"
    end.join
  end

  def process_calendar_data
    @lines = @calendar_data_no_color.split("\n").map do |line|
      next if line.strip.empty?
      next unless line.match(/^\d{1,2}:\d{2}(am|pm)/)
      time, item = line.split(/\s{2,}/, 2)
      "\\#{time}|\\#{item.strip}"
    end.compact
  end

  def gday
    output = ""
    output << generate_header
    output << "\n"
    output << TITLE
    output << "\n"
    output << TABLE_HEADER
    output << "\n"
    output << TABLE_SEPARATOR
    output << "\n"
    output << generate_body
    output << KICKER
    puts output
  end
end
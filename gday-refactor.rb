# version 0.1.1

require 'date'
require 'time'

class GDay
  EMOJI_MAP = {
    800 => "🕗", 830 => "🕣", 900 => "🕘", 930 => "🕤",
    1000 => "🕙", 1030 => "🕥", 1100 => "🕚", 1130 => "🕦",
    1200 => "🕛", 1230 => "🕧", 100 => "🕐", 130 => "🕜",
    200 => "🕑", 230 => "🕝", 300 => "🕒", 330 => "🕞",
    400 => "🕓", 430 => "🕟", 500 => "🕔", 530 => "🕠",
    600 => "🕕", 630 => "🕡", 700 => "🕖", 730 => "🕢"
  }

  TITLE = "## 🪢 Todo Today"
  TABLE_HEADER = "| Time    | Item |"
  TABLE_SEPARATOR = "|---------|------|"
  KICKER = "\n******* DO WHATEVER THE SCHEDULE TELLS ME. AND ONLY THAT.**********\n\n### Brain Dump (for 👑s)\n\n\n --- \n\n\n- 1st 🐸 I'll eat:\n- 2nd 🐸 I'll eat:\n- 3rd 🐸 I'll eat:\n\n"

  def initialize
    @calendar_data = get_calendar_data
    @calendar_data_no_color = remove_ansi_codes(@calendar_data)
    @lines = []
  end

  def gday
    puts "    🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞"
    puts "    🌞🌞🌞   gday Version 1.31.0    🌞🌞🌞"
    puts "    🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞🌞 \n\n"

    process_calendar_data

    h1 = generate_header
    body = generate_body

    puts "#{h1}\n\n#{TITLE}\n#{TABLE_HEADER}\n#{TABLE_SEPARATOR}\n#{body}\n\n#{KICKER}"
  end

  private

  def get_calendar_data
    `gcalcli --cal "JPB-DW" --cal "Pomo" --cal "JPB SL" --cal "JPB Private" agenda "1am today" "11pm today" --nocolor --no-military --details length`
  end

  def remove_ansi_codes(data)
    data.gsub(/\x1b\[[0-9;]*m/, '').gsub('|', '—')
  end

  def add_pomodoro(time)
    (Time.parse(time) + 30 * 60).strftime("%I:%M%p").downcase.sub(/^0/, '')
  end

  def process_calendar_data
    lines = @calendar_data_no_color.lines
    lines.each_with_index do |line, index|
      line.strip!
      next if line.empty?

      if line.match?(/^[0-9]{1,2}:[0-9]{2}[apm]{2}/)
        time, item = line.split(' ', 2)
        next_line = lines[index + 1] if index + 1 < lines.size
        next unless next_line

        duration_raw = next_line.match(/Length: (\d+:\d+)/)[1]
        hours, minutes = duration_raw.split(':').map(&:to_i)
        total_minutes = hours * 60 + minutes
        blocks = total_minutes / 30

        blocks.times do
          @lines << "#{time}|#{item}"
          time = add_pomodoro(time)
        end
      end
    end
  end

  def generate_header
    day_of_week = Date.today.strftime('%A')
    h1 = "# #{Date.today.strftime('%m/%d')} - #{day_of_week}"
    h1 += " - 📆 Week #{Date.today.strftime('%V')}" if day_of_week == "Monday"
    h1
  end

  def generate_body
    body = ""
    @lines.each do |line|
      time, item = line.split('|', 2)
      time_number = time.gsub(/[^0-9]/, '').to_i
      unless item.match?(/^[^[:alnum:]]/)
        emoji = EMOJI_MAP[time_number]
        item = "#{emoji} #{item}"
      end
      body += "| #{time} | #{item} |\n"
    end
    body
  end
end

GDay.new.gday

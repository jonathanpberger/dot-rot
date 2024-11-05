require 'rspec'
require_relative '../lib/gday'
require 'open3'
require 'timecop'

RSpec.describe Gday do
  let(:calendar_fixture) do
    <<~CALENDAR
    start_date      start_time      end_date        end_time        title
    2024-11-05      08:30   2024-11-05      09:00   🍅
    2024-11-05      09:00   2024-11-05      09:30   🍅
    2024-11-05      09:30   2024-11-05      10:00   🍅
    2024-11-05      09:30   2024-11-05      10:00   🪢 🪢 Todo today / run `todos` / review ⭐️ emails
    2024-11-05      10:00   2024-11-05      10:30   🍅
    2024-11-05      10:00   2024-11-05      11:00   💂 Options (Job hunt)
    2024-11-05      10:30   2024-11-05      11:00   🍅
    2024-11-05      11:00   2024-11-05      11:30   🍅
    2024-11-05      11:30   2024-11-05      12:00   🍅
    2024-11-05      12:00   2024-11-05      12:30   🍅
    2024-11-05      12:00   2024-11-05      12:45   🍜 Lunch
    2024-11-05      12:30   2024-11-05      13:00   🍅
    2024-11-05      12:45   2024-11-05      13:00   🐸 15m of Monarch categorization
    2024-11-05      13:00   2024-11-05      13:30   🍅
    2024-11-05      13:00   2024-11-05      15:00   🧱 ++Project time
    2024-11-05      13:00   2024-11-05      13:30   🐸 Eat 3 frogs
    2024-11-05      13:30   2024-11-05      14:00   🍅
    2024-11-05      13:30   2024-11-05      14:00   🧹 Knock out ~3 nitty-gritties
    2024-11-05      14:00   2024-11-05      14:30   🍅
    2024-11-05      14:30   2024-11-05      15:00   🍅
    2024-11-05      15:00   2024-11-05      15:30   🍅
    2024-11-05      15:00   2024-11-05      15:45   HOLD for Rottnek
    2024-11-05      15:30   2024-11-05      16:00   🍅
    2024-11-05      15:30   2024-11-05      17:00   👑 (A) priority important and non-urgent only!
    2024-11-05      16:00   2024-11-05      16:30   🍅
    2024-11-05      16:30   2024-11-05      17:00   🍅
    2024-11-05      17:00   2024-11-05      17:30   🍅
    2024-11-05      17:00   2024-11-05      17:15   🍒 What did you 🚢 today?
    2024-11-05      17:00   2024-11-05      19:00   🕯️ JPB works late
    CALENDAR
  end

  describe 'Extract phase' do
    it 'EXTRACTS calendar data from a fixture' do
      events = Gday.parse_tsv(calendar_fixture)
      expect(events.first).to include(
        time: "08:30",
        title: "🍅",
        end_time: "09:00"
      )
    end

    it 'EXTRACTS events with non-standard times' do
      events = Gday.parse_tsv(calendar_fixture)
      odd_time_event = events.find { |e| e[:time] == "12:45" }
      expect(odd_time_event[:title]).to include("15m of Monarch")
    end
  end

  describe 'Transform phase' do
    it 'TRANSFORMS events to align with pomodoro schedule' do
      events = Gday.parse_tsv(calendar_fixture)
      aligned_events = Gday.align_to_pomodoros(events)

      times = aligned_events.map { |e| e[:time] }
      expect(times).to all(match(/:(00|30)$/)) # Only :00 or :30
    end

    it 'TRANSFORMS by removing duplicate pomodoros' do
      events = Gday.parse_tsv(calendar_fixture)
      cleaned_events = Gday.remove_duplicate_pomodoros(events)

      # At 10:00, we should only have Options, not the pomodoro
      events_at_1000 = cleaned_events.select { |e| e[:time] == "10:00" }
      expect(events_at_1000.length).to eq(1)
      expect(events_at_1000.first[:title]).to include("Options")
    end

    it 'TRANSFORMS by adding emoji to emoji-free events' do
      events = Gday.parse_tsv(calendar_fixture)
      with_emoji = Gday.add_missing_emoji(events)

      hold_event = with_emoji.find { |e| e[:title].include?("HOLD") }
      expect(hold_event[:title]).to start_with("🕒")
    end

    it 'TRANSFORMS long events into 30-minute blocks' do
      events = Gday.parse_tsv(calendar_fixture)
      expanded = Gday.expand_long_events(events)

      # Project time (2 hours) should be split into four 30-min blocks
      project_events = expanded.select { |e| e[:title].include?("++Project time") }
      expect(project_events.length).to eq(4)
    end
  end

  describe 'Load phase' do
    it 'LOADS calendar data as a markdown table' do
      result = Gday.to_markdown_table(calendar_fixture)

      # Use regex to match regardless of exact spacing
      expect(result).to match(/\|\s*Time\s*\|\s*Item\s*\|/)
      expect(result).to match(/\|\s*-+\s*\|\s*-+\s*\|/)
      expect(result).to match(/\|\s*8:30am\s*\|\s*🍅\s*\|/)
      expect(result).to match(/\|\s*5:00pm\s*\|\s*🕯️ JPB works late\s*\|/)
    end

    it 'LOADS empty input as empty table' do
      empty_data = "start_date      start_time      end_date        end_time        title\n"
      result = Gday.to_markdown_table(empty_data)

      # Use regex to match regardless of exact spacing
      expect(result).to match(/\|\s*Time\s*\|\s*Item\s*\|/)
      expect(result).to match(/\|\s*-+\s*\|\s*-+\s*\|/)
    end

    it 'LOADS times in consistent format' do
      result = Gday.to_markdown_table(calendar_fixture)

      # Use regex to match regardless of exact spacing
      expect(result).to match(/\|\s*8:30am\s*\|/)   # No leading zero
      expect(result).to match(/\|\s*10:00am\s*\|/)  # Double-digit hour
      expect(result).to match(/\|\s*2:00pm\s*\|/)   # Afternoon, no leading zero
    end
  end
end


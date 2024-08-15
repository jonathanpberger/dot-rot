# gday_spec.rb
# version 0.1.4

require 'rspec'
require_relative './gday'

RSpec.describe GDay do
  let(:gday_instance) { GDay.new }
  let(:calendar_data) do
    <<~DATA
      Thu Aug 08           Office
                           Length: 1 day, 0:00:00
                  8:00am             🪢 Todo today / review GH Issues / run `todos`
                           Length: 0:30:00
                  8:30am             🍅
                           Length: 0:30:00
                  8:30am             🐸 Eat 3 frogs
                           Length: 0:30:00
                  8:45am             🐸 15m of Monarch categorization
                           Length: 0:15:00
                  9:00am             🍅
                           Length: 0:30:00
                  9:00am             11W improvement mtg / IPM
                           Length: 1:00:00
                  9:30am             🍅
                           Length: 0:30:00
                  10:00am            🍅
                           Length: 0:30:00
                  10:00am            👑 A-priority only focus time
                           Length: 1:30:00
                  10:30am            🍅
                           Length: 0:30:00
                  11:00am            🍅
                           Length: 0:30:00
                  11:00am            Infra Standup
                           Length: 0:20:00
                  11:30am            🍅
                           Length: 0:30:00
                  11:30am            JPB / Lucy 1:1
                           Length: 0:30:00
                  12:00pm            🍅
                           Length: 0:30:00
                  12:00pm            Protocol Eng Sync
                           Length: 2:00:00
                  12:00pm            Rottnek
                           Length: 0:30:00
                  12:30pm            🍅
                           Length: 0:30:00
                  12:30pm            Andy / Jonathan
                           Length: 0:30:00
                  1:00pm             🍅
                           Length: 0:30:00
                  1:30pm             🍅
                           Length: 0:30:00
                  1:30pm             🍜 Lunch
                           Length: 0:30:00
                  2:00pm             🍅
                           Length: 0:30:00
                  2:00pm             Reece / Jonathan
                           Length: 0:30:00
                  2:30pm             🍅
                           Length: 0:30:00
                  2:30pm             Justin / Jonathan
                           Length: 0:30:00
                  3:00pm             🍅
                           Length: 0:30:00
                  3:00pm             Groom stories in GH backlogs
                           Length: 1:00:00
                  3:00pm             🧹 Knock out ~3 nitty-gritties
                           Length: 0:30:00
                  3:30pm             🍅
                           Length: 0:30:00
                  4:00pm             🍅
                           Length: 0:30:00
                  4:15pm             ICF 2025 Funding Proposal Jam
                           Length: 1:00:00
                  4:30pm             🍅
                           Length: 0:30:00
                  5:00pm             🍅
                           Length: 0:30:00
                  5:00pm             🍒 What did you 🚢 today?
                           Length: 0:15:00
    DATA
  end

  before do
    allow(gday_instance).to receive(:get_calendar_data).and_return(calendar_data)
    gday_instance.instance_variable_set(:@calendar_data_no_color, gday_instance.send(:remove_ansi_codes, calendar_data))
  end

  describe '#initialize' do
    it 'initializes with calendar data and removes ANSI codes' do
      expected_data = calendar_data.gsub(/\e\[[0-9;]*m/, '')
      actual_data = gday_instance.instance_variable_get(:@calendar_data_no_color)
      expect(actual_data).to eq(expected_data)
    end
  end

  describe '#add_pomodoro' do
    it 'adds 30 minutes to a given time' do
      expect(gday_instance.send(:add_pomodoro, '9:00am')).to eq('9:30am')
      expect(gday_instance.send(:add_pomodoro, '11:45pm')).to eq('12:15am')
    end
  end

  describe '#generate_header' do
    it 'generates the correct header for a given day' do
      allow(Date).to receive(:today).and_return(Date.parse('2024-08-08'))
      expect(gday_instance.send(:generate_header)).to eq("# 08/08 - Thursday")

      allow(Date).to receive(:today).and_return(Date.parse('2024-08-05'))
      expect(gday_instance.send(:generate_header)).to eq("# 08/05 - Monday - 📆 Week 32")
    end
  end

  describe '#generate_body' do
    it 'generates the correct body with time and items' do
      gday_instance.instance_variable_set(:@lines, ["9:00am|Meeting with team", "9:30am|Code review"])
      expect(gday_instance.send(:generate_body)).to eq("| 9:00am | 🕘 Meeting with team |\n| 9:30am | 🕤 Code review |\n")
    end
  end

  describe '#process_calendar_data' do
    it 'processes calendar data correctly' do
      gday_instance.send(:process_calendar_data)
      expect(gday_instance.instance_variable_get(:@lines)).to eq([
        "8:00am|🪢 Todo today / review GH Issues / run `todos`",
        "8:30am|🍅",
        "8:30am|🐸 Eat 3 frogs",
        # "8:45am|🐸 15m of Monarch categorization",
        "9:00am|🍅",
        "9:00am|11W improvement mtg / IPM",
        "9:30am|🍅",
        "10:00am|🍅",
        "10:00am|👑 A-priority only focus time",
        "10:30am|🍅",
        "11:00am|🍅",
        "11:00am|Infra Standup",
        "11:30am|🍅",
        "11:30am|JPB / Lucy 1:1",
        "12:00pm|🍅",
        "12:00pm|Protocol Eng Sync",
        "12:00pm|Rottnek",
        "12:30pm|🍅",
        "12:30pm|Andy / Jonathan",
        "1:00pm|🍅",
        "1:30pm|🍅",
        "1:30pm|🍜 Lunch",
        "2:00pm|🍅",
        "2:00pm|Reece / Jonathan",
        "2:30pm|🍅",
        "2:30pm|Justin / Jonathan",
        "3:00pm|🍅",
        "3:00pm|Groom stories in GH backlogs",
        "3:00pm|🧹 Knock out ~3 nitty-gritties",
        "3:30pm|🍅",
        "4:00pm|🍅",
        "4:15pm|ICF 2025 Funding Proposal Jam",
        "4:45pm|ICF 2025 Funding Proposal Jam",
        "4:30pm|🍅",
        "5:00pm|🍅",
        "5:00pm|🍒 What did you 🚢 today?"
      ])
    end
  end

  describe "#foo" do
    it "does something" do
      puts "foo"
    end
  end

  describe '#gday' do
    it 'outputs the correct schedule' do
      allow(Date).to receive(:today).and_return(Date.parse('2024-08-08'))
      expect { gday_instance.gday }.not_to raise_error
    end
  end
end

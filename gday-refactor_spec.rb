# spec/gday_spec.rb
# version 0.1.0

require 'rspec'
require_relative './gday-refactor'

RSpec.describe GDay do
  let(:gday_instance) { GDay.new }

  describe '#initialize' do
    it 'initializes with calendar data and removes ANSI codes' do
      expect(gday_instance.instance_variable_get(:@calendar_data)).to be_a(String)
      expect(gday_instance.instance_variable_get(:@calendar_data_no_color)).to be_a(String)
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


  describe '#gday' do
    it 'outputs the correct schedule' do
      allow(gday_instance).to receive(:puts)
      allow(gday_instance).to receive(:get_calendar_data).and_return("")

      allow(Date).to receive(:today).and_return(Date.parse('2024-08-08'))

      gday_instance.instance_variable_set(:@calendar_data_no_color, "9:00am Meeting with team\nLength: 1:00\n")
      expect { gday_instance.gday }.not_to raise_error
    end
  end
end

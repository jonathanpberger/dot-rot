# Version: 1.0.1
require 'httparty'
require 'csv'
require 'json' # Ensure the JSON library is required
require 'awesome_print'


# Function to read .secrets file and parse the keys with a filter for specific services
def load_secrets(prefix)
  secrets = {}
  File.readlines('.secrets').each do |line|
    next if line.strip.empty? || line.strip.start_with?('#') || !line.strip.start_with?(prefix)

    key, value = line.strip.split('=')
    if key && value
      secrets[key.strip] = value.strip # Ensure no extra whitespace
    else
      puts "Warning: Skipping malformed line in .secrets file: #{line}"
    end
  end
  secrets
end

# Load only the Trello-related credentials
secrets = load_secrets('TRELLO_')

TRELLO_API_KEY = secrets['TRELLO_API_KEY']
TRELLO_TOKEN = secrets['TRELLO_TOKEN']
TRELLO_BOARD_ID = 'N2XoouQE' # The Fair Play Template Board ID


# Validate that the required secrets are present
if TRELLO_API_KEY.nil? || TRELLO_TOKEN.nil? || TRELLO_BOARD_ID.nil?
  raise 'Error: Missing Trello API credentials in .secrets file'
end

# Trello API URL
BASE_URL = "https://api.trello.com/1"

# Function to fetch board data
def fetch_board_data(board_id)
  url = "#{BASE_URL}/boards/#{board_id}/cards?fields=name,desc,labels&key=#{TRELLO_API_KEY}&token=#{TRELLO_TOKEN}"
  response = HTTParty.get(url)
  raise "Error fetching data: #{response.message}" unless response.success?

  response.parsed_response

  ap response.first(2).parsed_response
end


# Function to write data to CSV
def parse_sections(description)
  return {} if description.nil? || description.empty?

  sections = {
    'definition' => '',
    'conception' => '',
    'planning' => '',
    'execution' => '',
    'minimum_standard_of_care' => ''
  }

  current_section = nil
  description.split("\n").each do |line|
    line = line.strip

    case line
    when /^Definition/i
      current_section = 'definition'
    when /^Conception/i
      current_section = 'conception'
    when /^Planning/i
      current_section = 'planning'
    when /^Execution/i
      current_section = 'execution'
    when /^Minimum Standard of Care/i
      current_section = 'minimum_standard_of_care'
    else
      if current_section && !line.empty?
        sections[current_section] += sections[current_section].empty? ? line : "\n#{line}"
      end
    end
  end

  sections
end

def write_to_csv(cards, filename = 'fairplay_cards_new.csv')
  CSV.open(filename, 'w') do |csv|
    csv << ['ID', 'Name', 'Definition', 'Conception', 'Planning', 'Execution', 'Minimum Standard of Care', 'Labels']

    Array(cards).each do |card|
      sections = parse_sections(card['desc'])
      labels = card['labels'] ? card['labels'].map { |label| label['name'] }.join(', ') : ''

      csv << [
        card['id'],
        card['name'],
        sections['definition'],
        sections['conception'],
        sections['planning'],
        sections['execution'],
        sections['minimum_standard_of_care'],
        labels
      ]
    end
  end
  puts "Data exported to #{filename}"
end

begin
  puts 'Fetching Fairplay Trello board data...'
  cards = fetch_board_data(TRELLO_BOARD_ID)
  write_to_csv(cards)
rescue StandardError => e
  puts "Error: #{e.message}"
end
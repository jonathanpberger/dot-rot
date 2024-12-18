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
  url = "#{BASE_URL}/boards/#{board_id}/cards?fields=name,desc&labels=all&key=#{TRELLO_API_KEY}&token=#{TRELLO_TOKEN}"
  response = HTTParty.get(url)
  raise "Error fetching data: #{response.message}" unless response.success?

  response.parsed_response

  ap response.parsed_response
end


# Function to write data to CSV
def parse_sections(description)
  # Define all possible section headers and their variations
  section_patterns = {
    'definition' => /^Definition:?\s*/i,
    'conception' => /^Conception:?\s*/i,
    'planning' => /^Planning:?\s*/i,
    'execution' => /^Execution:?\s*/i,
    'standard' => /^Minimum Standard of Care:?\s*/i
  }

  # Initialize result hash with nil values for all sections
  result = section_patterns.keys.map { |k| [k, nil] }.to_h

  return result if description.nil? || description.empty?

  # Split into sections more robustly
  sections = description.split(/(?:^|\n)(?=[A-Za-z][^:\n]*:)/m)

  sections.each do |section|
    section = section.strip
    section_patterns.each do |key, pattern|
      if section.match?(pattern)
        # Extract content after the header
        content = section.sub(pattern, '').strip
        result[key] = content unless content.empty?
        break  # Stop checking patterns once we find a match
      end
    end
  end

  result
end

def write_to_csv(cards, filename = 'fairplay_cards.csv')
  CSV.open(filename, 'w') do |csv|
    column_headers = %w[Title Description Labels Definition Conception Planning Execution Standard]
    csv << column_headers

    cards.each do |card|
      labels = card['labels'] ? card['labels'].map { |label| label['name'] }.join(', ') : ''

      # Parse sections using our new function
      sections = parse_sections(card['desc'])

      csv << [
        card['name'],
        card['desc'],
        labels,
        sections['definition'],
        sections['conception'],
        sections['planning'],
        sections['execution'],
        sections['standard']
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
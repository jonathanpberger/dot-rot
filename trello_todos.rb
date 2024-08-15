# version 0.7.0
require 'httparty'
require 'json'

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
TRELLO_BOARD_ID = secrets['TRELLO_BOARD_ID']

# Ensure all required variables are loaded
if TRELLO_API_KEY.nil? || TRELLO_API_KEY.empty? ||
   TRELLO_TOKEN.nil? || TRELLO_TOKEN.empty? ||
   TRELLO_BOARD_ID.nil? || TRELLO_BOARD_ID.empty?
  puts "Error: One or more required fields are missing in the .secrets file."
  exit 1
end

# Function to get the board's name
def fetch_board_name
  url = "https://api.trello.com/1/boards/#{TRELLO_BOARD_ID}?key=#{TRELLO_API_KEY}&token=#{TRELLO_TOKEN}"
  response = HTTParty.get(url)

  if response.success?
    JSON.parse(response.body)['name']
  else
    puts "Failed to fetch board name from Trello API"
    puts "Response code: #{response.code}"
    puts "Response message: #{response.message}"
    puts "Response body: #{response.body}"
    nil
  end
end

# Function to get cards (todos) from the Trello board
def fetch_trello_cards
  url = "https://api.trello.com/1/boards/#{TRELLO_BOARD_ID}/cards?key=#{TRELLO_API_KEY}&token=#{TRELLO_TOKEN}"
  response = HTTParty.get(url)

  if response.success?
    JSON.parse(response.body)
  else
    puts "Failed to fetch cards from Trello API"
    []
  end
end

# Function to get list names for the board
def fetch_trello_lists
  url = "https://api.trello.com/1/boards/#{TRELLO_BOARD_ID}/lists?key=#{TRELLO_API_KEY}&token=#{TRELLO_TOKEN}"
  response = HTTParty.get(url)

  if response.success?
    JSON.parse(response.body).each_with_object({}) { |list, hash| hash[list['id']] = list['name'] }
  else
    puts "Failed to fetch lists from Trello API"
    {}
  end
end

# Function to format cards and their corresponding lists as markdown
def format_as_markdown(cards, lists)
  cards.map do |card|
    list_name = lists[card['idList']]
    "- [ ] [#{list_name}] #{card['name']} (#{card['shortUrl']})"
  end.join("\n")
end

# Fetch the board name
board_name = fetch_board_name

if board_name
  # Fetch cards and lists
  cards = fetch_trello_cards
  lists = fetch_trello_lists

  if cards.empty?
    puts "No cards found"
  else
    puts "### Board: #{board_name}\n\n"
    puts format_as_markdown(cards, lists)
  end
else
  puts "Failed to retrieve board name, cannot continue."
end

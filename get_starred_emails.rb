# v2.2.0
require 'json'
require 'google/apis/gmail_v1'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'
require 'clipboard'  # Add clipboard gem for pasteboard access
require 'time'       # Add Time for date formatting

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'.freeze
APPLICATION_NAME = 'Gmail API Ruby Quickstart'.freeze
TOKEN_PATH = 'token.yaml'.freeze
SCOPE = Google::Apis::GmailV1::AUTH_GMAIL_READONLY
MAX_RESULTS = 140 # Explicitly set API limit
CHAR_LIMIT = 12   # Character limit for sender name and email
SEPARATOR = " ⭐️📧 "  # Updated separator between email and subject

def load_secrets
  credentials_json = ENV['GMAIL_API_CREDENTIALS']
  if credentials_json.nil?
    raise "GMAIL_API_CREDENTIALS environment variable not set."
  end
  JSON.parse(credentials_json)
end

def authorize
  credentials = load_secrets()

  # Save credentials to temporary file to work with Google API
  File.open('credentials_temp.json', 'w') do |file|
    file.write(credentials.to_json)
  end

  client_id = Google::Auth::ClientId.from_file('credentials_temp.json')
  token_store = Google::Auth::Stores::FileTokenStore.new(file: TOKEN_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)

  if credentials.nil?
    url = authorizer.get_authorization_url(base_url: OOB_URI)
    puts 'Open the following URL in your browser and enter the resulting code after authorization:'
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI
    )
  end

  File.delete('credentials_temp.json') # Clean up temp credentials file

  credentials
end

def extract_sender(headers)
  sender_header = headers.find { |h| h.name == 'From' }
  if sender_header
    # Extract the name and email from the sender header
    if sender_header.value =~ /"?([^"]*)"?\s*<(.+)>/
      sender_name = $1
      sender_email = $2
    else
      sender_name = sender_header.value
      sender_email = ''
    end
    # Truncate sender name and email to the character limit
    sender_name = sender_name[0, CHAR_LIMIT].ljust(CHAR_LIMIT, ' ')
    sender_email = sender_email[0, CHAR_LIMIT].ljust(CHAR_LIMIT, ' ')
    return sender_name, sender_email
  else
    return 'Unknown    ', 'Unknown    '
  end
end

def format_date(msg_data)
  internal_date = msg_data.internal_date
  date = Time.at(internal_date / 1000) # Convert milliseconds to seconds
  date.strftime("%m/%d") # Format as MM/DD
end

def get_starred_emails(service)
  # Set maxResults to limit the number of emails fetched
  result = service.list_user_messages('me', q: 'is:starred', max_results: MAX_RESULTS)
  messages = result.messages
  if messages.nil?
    puts 'No starred emails found.'
    return
  end

  # Initialize counter
  count = messages.size

  # Print the total count of starred emails
  puts "\nTotal Starred Emails: #{count}\n\n"

  # Collect all the email details in a list
  email_list = ""

  messages.each do |msg|
    msg_data = service.get_user_message('me', msg.id)
    headers = msg_data.payload.headers

    # Extract sender name and email
    sender_name, sender_email = extract_sender(headers)

    # Extract subject
    subject = headers.find { |h| h.name == 'Subject' }&.value || 'No Subject'

    # Extract and format the date
    formatted_date = format_date(msg_data)

    # Format each email as a markdown todo with date and custom separator
    formatted_email = "- [ ] #{sender_name} #{sender_email} #{formatted_date}#{SEPARATOR}#{subject}\n"

    # Add to the email list and print to the terminal
    email_list += formatted_email
    puts formatted_email
  end

  # Copy the email list to the clipboard
  Clipboard.copy(email_list)

  # Print a message to confirm the list is on the clipboard
  puts "\nThe list of starred emails has been copied to the clipboard."
end

Gmail = Google::Apis::GmailV1
service = Gmail::GmailService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

get_starred_emails(service)

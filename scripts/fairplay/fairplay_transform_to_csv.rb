require 'json'
require 'csv'

# Define input and output file paths
INPUT_FILE = 'fairplay_cards.json'
OUTPUT_FILE = 'fairplay_cards_transformed.csv'

def transform_json_to_csv(input_file, output_file)
  # Read and parse the JSON file
  cards = JSON.parse(File.read(input_file))
  
  # Define the columns for the CSV
  columns = %w[Name Definition Conception Planning Execution Minimum_Standard Labels]

  # Open the CSV file for writing
  CSV.open(output_file, 'w') do |csv|
    # Write the header row
    csv << columns

    # Write each card's data
    cards.each do |card|
      csv << [
        card['Title'],                                # Name
        card['Definition'],                          # Definition
        card['Conception'],                          # Conception
        card['Planning'],                            # Planning
        card['Execution'],                           # Execution
        card['Standard'],                            # Minimum Standard
        card['Labels'] ? card['Labels'].join(', ') : '' # Labels
      ]
    end
  end

  puts "Data successfully transformed to #{output_file}"
end

# Run the transformation
begin
  transform_json_to_csv(INPUT_FILE, OUTPUT_FILE)
rescue StandardError => e
  puts "Error: #{e.message}"
end
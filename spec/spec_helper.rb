RSpec.configure do |config|
  config.before(:suite) do
    # Verify required files exist
    raise "Missing aliases file" unless File.exist?(File.expand_path("~/.oh-my-zsh/custom/aliases.zsh"))
    raise "Missing gcalcli" unless system("which gcalcli > /dev/null 2>&1")
  end
end
DOTROT_HOME = File.dirname(__FILE__)
DOTROT_BACKUPS = File.join(DOTROT_HOME, 'backups')

require 'lib/dotrot'

task :default => [:install]

desc "Install dotfiles"
task :install do
  symlink_dotfile "bash_profile"
  symlink_dotfile "gitconfig"
  symlink_dotfile "gemrc"
  symlink_dotfile "zshrc"
  KeyBindingsInstaller.install!
  puts "\nNow run this command to reload the shell:\n\n"
  puts "  source ~/.bash_profile\n\n"
end

namespace :backups do
  desc "Clobber backups"
  task :clobber do
    print "=> removing #{DOTROT_BACKUPS}... "
    FileUtils.rm_rf(DOTROT_BACKUPS)
    puts "done!"
  end
  
  desc "Restore backups"
  task :restore do
    print "=> restoring from backups... "
    FileUtils.mv File.join(DOTROT_BACKUPS, '*'), File.join(ENV['HOME']), :force => true
    puts "done!"
  end
end

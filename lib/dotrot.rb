class KeyBindingsInstaller
  PATH = File.join(ENV['HOME'], *%W[Library KeyBindings DefaultKeyBinding.dict])
  
  def self.install!
    return if File.exist?(PATH)
    puts '** Installing KeyBindings'
    puts ' * Creating ~/Library/KeyBindings directory'
    FileUtils.mkdir_p(File.dirname(PATH))
    puts ' * Linking file...'
    FileUtils.ln_s \
      source = File.join(DOTROT_HOME, 'nakajima', 'DefaultKeyBinding.dict'),
      target = PATH
    puts ' * done!'
  end
end

def symlink_dotfile(name)
  source = File.join(DOTROT_HOME, "dot.#{name}")
  target = File.join(ENV['HOME'], ".#{name}")
  
  backup_dotfile(target)

  puts "** symlinking #{name}... "
  FileUtils.ln_s source, target
  puts '** done!'
  puts
end

def backup_dotfile(target)
  if File.exists?(target)
    name = File.basename(target)
    puts "** moving old #{name} to #{DOTROT_BACKUPS}/#{name}"
    FileUtils.rm_rf(File.join(DOTROT_BACKUPS, name))
    FileUtils.mkdir_p(DOTROT_BACKUPS)
    FileUtils.mv target, File.join(DOTROT_BACKUPS, name), :force => true
  end
end

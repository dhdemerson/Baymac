class Mackup
  attr_accessor :installed

DEFAULT_CONFIG = """[storage]
engine = file_system
path = #{Dir.pwd}/.baymac/mackup/"""

  def initialize()
    @installed = $IOX.commandSuccess?('type mackup')
  end

  def install
    $IOX.say "Installing Mackup... "
    $IOX.run("brew install mackup")

    unless $IOX.commandSuccess?('type mackup')
      puts "\n"
      $IOX.sad "It seems like Mackup failed to install..."
    else
      $IOX.add "Mackup installed!"
      @installed = true
    end
  end

  def installed?
    return @installed
  end

  def backup
    $IOX.say "Copying configs... "

    userConfig = false

    # Don't overwrite existing configuration
    if File.exist?(ENV['HOME'] + "/.mackup.cfg")
      file = File.open(ENV['HOME'] + "/.mackup.cfg", "r")
      userMackupConfig = file.read
      userConfig = true
    end

    # Temporarily use our configuration
    File.write(ENV['HOME'] + "/.mackup.cfg", DEFAULT_CONFIG)
    $IOX.run("mackup -f backup")

    # Restore existing configuration leave ours if there was none
    if userConfig
      File.write(ENV['HOME'] + "/.mackup.cfg", userMackupConfig)
    end

    $IOX.add "Done!"
  end

  def restore
    $IOX.say "Linking configurations... "

    userConfig = false

    # Don't overwrite existing configuration
    if File.exist?(ENV['HOME'] + "/.mackup.cfg")
      file = File.open(ENV['HOME'] + "/.mackup.cfg", "r")
      userMackupConfig = file.read
      userConfig = true
    end

    # Temporarily use our configuration
    File.write(ENV['HOME'] + "/.mackup.cfg", DEFAULT_CONFIG)
    $IOX.run("mackup restore")

    # Restore existing configuration leave ours if there was none
    if userConfig
      File.write(ENV['HOME'] + "/.mackup.cfg", userMackupConfig)
    end

    $IOX.add "Done!"
  end
end

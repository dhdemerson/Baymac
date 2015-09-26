class Cask
  attr_accessor :installed

  def initialize(homebrew)
    @homebrew = homebrew
    @installed = @homebrew.installed? && $IOX.commandSuccess?('brew cask')
    @apps = $IOX.configRead('cask', [])
  end

  def install
    $IOX.say "Installing Homebrew Cask... "
    $IOX.run("brew install caskroom/cask/brew-cask")
    # TODO: Check cask installation
    $IOX.add "Homebrew Cask installed!"
    @installed = true
  end

  def installed?
    return @installed
  end

  def apps
    return @apps
  end

  def setApps(apps)
    @apps = apps
    $IOX.configWrite('cask', @apps)
  end

  def installApps
    @apps.each do |app|
      $IOX.say "Installing #{app}... "
      $IOX.run("brew cask install #{app}")
      $IOX.add "Done!"
    end
  end
end

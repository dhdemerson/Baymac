class Homebrew
  attr_accessor :installed, :upToDate

  def initialize
    @installed = $IOX.commandSuccess?('type brew')
    @upToDate = false # TODO: use date from brew -v
  end

  def install
    $IOX.say "Okay, running the Homebrew installation script"
    $IOX.say "This process may prompt you for your password"
    system 'ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"'

    unless $IOX.commandSuccess?('type brew')
      $IOX.sad "It seems like Homebrew failed to install..."
      @installed = false
      @upToDate = false
    else
      @installed = true
      @upToDate = true
      $IOX.say "Homebrew installed!"
    end
  end

  def update
    $IOX.say "Updating Homebrew... "
    $IOX.run("brew update")
    @upToDate = true
    $IOX.add (" Done.")
  end

  def installed?
    return @installed
  end

  def upToDate?
    return @upToDate
  end

end

require 'highline'
require 'yaml'
require 'singleton'

class IOX
  include Singleton

  def initialize()
    @IOXterminal = HighLine.new
    @IOXterminal.indent_size = 3
    @IOXterminal.wrap_at = @IOXterminal.terminal_size[0]
    @IOXterminal.indent_level = 0;
    @verbose = false
  end

  BAYMAC = "[<%= color('·_·', BOLD) %>] "
  SAD_BAYMAC = "[._.] "

  def setVerbose(verbose)
    @verbose = verbose
  end

  def commandSuccess?(cmd)
    stdouterr, status = Open3.capture2e("#{cmd}")
    status.success?
  end

  def configWrite(config, object)
    File.open(".baymac/configs/" + config + ".yaml", 'w') { |file| file.write(YAML::dump(object))}
  end

  def configRead(config, default)
    if File.exists? (".baymac/configs/" + config + ".yaml")
      config = File.open(".baymac/configs/" + config + ".yaml", 'r')
      return YAML::load(config)
    else
      return default
    end
  end

  def run(cmd)
    Open3.popen2e(cmd) { |stdin, stdout_stderr, wait_thr|
      stdout_stderr.each { |line|
        if @verbose
          puts line
        end
      }
    }
  end

  def say(input, pause=true)
    @IOXterminal.wrap_at = @IOXterminal.terminal_size[0]
    @IOXterminal.say "\n" + BAYMAC + input
  end

  def add(input)
    @IOXterminal.say input
  end

  def sad(input)
    @IOXterminal.wrap_at = @IOXterminal.terminal_size[0]
    @IOXterminal.say "\n" + SAD_BAYMAC + input
  end

  def increaseIndentLevel
    @IOXterminal.indent_level += 2
  end

  def decreaseIndentLevel
    @IOXterminal.indent_level -= 2
  end

  def list(lines)
    @IOXterminal.wrap_at = @IOXterminal.terminal_size[0]
    @IOXterminal.indent_level = 2
    lines.each do |line|
      if line.is_a? String
        @IOXterminal.say "• <%= color('#{line}', BOLD) %>"
      elsif line.is_a? Object
        @IOXterminal.say "• <%= color('#{line[:head]}', BOLD) %> #{line[:body]}"
      end
    end
    @IOXterminal.indent_level = 0
  end

  def ask(question)
    @IOXterminal.wrap_at = @IOXterminal.terminal_size[0]
    @IOXterminal.ask "\n" + BAYMAC + question
  end

  def agree(question)
    @IOXterminal.wrap_at = @IOXterminal.terminal_size[0]
    @IOXterminal.agree "\n" + question
  end

  def ynq(question)
    while(true)
      response = ask("? #{question} (yes/no/quit): ")
      case
      when "yes".include?(response.downcase)
        return true
      when "no".include?(response.downcase)
        return false
      when "quit".include?(response.downcase)
        sad "Okay... Goodbye!"
        abort
      end
      say "I'm sorry I didn't understand that..."
    end
  end
end

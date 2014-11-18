# Pry.config.history.should_save = true
# Pry.config.history.should_load = true
# Pry.config.history.file = ~/.pry_history

begin
  require "awesome_print"
  AwesomePrint.pry!
rescue LoadError => err
  puts "no awesome_print :("
end

# Pry navigation
if defined?(PryDebugger)
  # next: Step over to the next line within the same frame.
  # step: Step execution into the next line or method.
  # finish: Execute until current stack frame returns.
  # continue: Continue program execution and end the Pry session.
  Pry.commands.alias_command 'n', 'next'
  Pry.commands.alias_command 's', 'step'
  Pry.commands.alias_command 'f', 'finish'
  Pry.commands.alias_command 'c', 'continue'
  Pry.commands.alias_command 'w', 'whereami'
end

# Re-enable pry after having disabled it
Pry::Commands.block_command('enable-pry', 'Enable `binding.pry` feature') do
  ENV['DISABLE_PRY'] = nil
end

# Pry.config.history.should_save = true
# Pry.config.history.should_load = true
# Pry.config.history.file = ~/.pry_history

# Re-enable pry after having disabled it
Pry::Commands.block_command('enable-pry', 'Enable `binding.pry` feature') do
  ENV['DISABLE_PRY'] = nil
end

puts 'COVERAGE: Preparing to run coverage tests...'

puts "COVERAGE: Working Directory: #{Dir.pwd} (#{Dir.getwd})"

solution_path = File.expand_path('..', __dir__)
ruby_source_path = File.join(solution_path, 'src')
ruby_tests_path = File.join(solution_path, 'tests')
test_suite_path = File.join(ruby_tests_path, 'Shadow Texture')

puts 'COVERAGE: Loading SimpleCov...'

# https://github.com/colszowka/simplecov
require 'simplecov'
SimpleCov.root(solution_path)
SimpleCov.start

puts 'COVERAGE: Loading extension...'

$LOAD_PATH << ruby_source_path
require 'tt_shadow_texture.rb'

done = false
UI.start_timer(0.0, false) {
  next if done
  done = true

  puts 'COVERAGE: Loading TestUp...'

  require 'testup'
  # TODO: Check TestUp version.

  puts 'COVERAGE: Running tests...'

  # TODO: Add API method in TestUp that combine all this, to run without UI.
  options = {
    clear_console: false,
    show_console: true,
    verbose: true,
    ui: false,
  }
  test_suite = TestUp::API.discover_tests([test_suite_path]).first
  TestUp::API.run_test_suite(test_suite, options: options) { |results|
    # TODO: Check for failures.
  }

  puts 'COVERAGE: Terminating...'

  Sketchup.active_model.close(true) # Force close the test model.
  Sketchup.quit
}

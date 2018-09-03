# Launcher script for starting SketchUp in Ruby Debug mode.
version = ARGV[0].to_i
port = ARGV[1] || '7000'

if RUBY_PLATFORM =~ /darwin/
  sketchup_path = "/Applications/SketchUp #{version}"
  sketchup = File.join(sketchup_path, 'SketchUp.app')

  raise "SketchUp #{version} not found. (#{sketchup})" unless File.exist?(sketchup)

  command = %(open -a "#{sketchup}")
  command << %( --args -rdebug "ide port=#{port}")
else
  program_files_32bit = ENV['ProgramFiles(x86)']
  program_files_64bit = ENV['ProgramW6432']

  # Look for 32bit or 64bit SketchUp in default installation directory.
  paths = [program_files_32bit, program_files_64bit].map { |program_files|
    sketchup_path = File.join(program_files, 'SketchUp', "SketchUp #{version}")
    sketchup = File.join(sketchup_path, 'SketchUp.exe')
    File.expand_path(sketchup)
  }
  sketchup = paths.find { |path| File.exist?(path) }

  raise "SketchUp #{version} not found." if sketchup.nil?

  command = %("#{sketchup}" -rdebug "ide port=#{port}")
end

id = spawn(command)
Process.detach(id)

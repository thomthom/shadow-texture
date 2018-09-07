sketchup = "C:\\Program Files\\SketchUp\\SketchUp 2018\\SketchUp.exe"
script = File.join(__dir__, 'tools', 'coverage.rb')
args = "Proxy:Skip:shadow-texture"

command = %("#{sketchup}" -RubyStartup "#{script}" -RubyStartupArg "#{args}")

id = spawn(command)
Process.detach(id)

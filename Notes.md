A small note about RubyGems + FastRI
====================================
RubyGems adds a noticeable overhead to fri, making it run slower than if you
installed it directly from the tarball with setup.rb.

Compare the execution time when installed with RubyGems:
  $ time fri -f plain String > /dev/null

  real  0m0.385s
  user  0m0.244s
  sys   0m0.036s

to the time fri actually takes to run, without the overhead introduced by
RubyGems:
  $ time ruby bin/fri -f plain String > /dev/null

  real  0m0.088s
  user  0m0.040s
  sys   0m0.008s

If you care about those extra 300ms (and there are situations where they will
matter, e.g. when using fri for method completion), get FastRI from the
tarballs.


Coverage
========

Using `simpleconv`. (Uses native JSON gem which require compiling.)

```bash
"C:\Program Files\SketchUp\SketchUp 2018\SketchUp.exe" -RubyStartup "C:/Users/Thomas/SourceTree/shadow-texture/tools/coverage.rb" -RubyStartupArg "Proxy:Skip:shadow-texture"
```

```ruby
# SKETCHUP_CONSOLE.show
# puts '<ProxyLoad>'

skippables = []
if ARGV.size == 1 && ARGV[0].is_a?(String)
  args = ARGV[0].split(':')
  if args.size == 3 && args[0] == 'Proxy' && args[1] == 'Skip'
    skippables = args[2].split(';')
  end
end

paths = [
  'C:/Users/Thomas/SourceTree/tt-library-2',
  'C:/Users/Thomas/SourceTree/TestUp2/src',
  # 'C:/Users/Thomas/SourceTree/SKUI/src',
  # 'C:/Users/Thomas/SourceTree/vertex-tools/src',
  # 'C:/Users/Thomas/SourceTree/vertex-tools-v1',
  # 'C:/Users/Thomas/SourceTree/bezier-surface/src',
  # #'C:/Users/Thomas/SourceTree/tæst/bezier-surface/src',
  # #'C:/Users/Thomas/SourceTree/catmull-clark-subdivision',
  # #'C:/Users/Thomas/SourceTree/guide-tools/src',
  # 'C:/Users/Thomas/SourceTree/sketchup-stl/src',
  # 'C:/Users/Thomas/SourceTree/teapot',
  # 'C:/Users/Thomas/SourceTree/sketchup-attribute-helper/src',
  # 'C:/Users/Thomas/SourceTree/sketchup-safe-frames/src',
  # 'C:/Users/Thomas/SourceTree/cleanup',
  # #'C:/Users/Thomas/SourceTree/shader-tools/src',
  'C:/Users/Thomas/SourceTree/SpeedUp/src',
  'C:/Users/Thomas/SourceTree/solid-inspector/src',
  # 'C:/Users/Thomas/SourceTree/solid-inspector',
  'C:/Users/Thomas/SourceTree/SelectionTools/src',
  # 'C:/Users/Thomas/SourceTree/uv-toolkit/src',
  'C:/Users/Thomas/SourceTree/quadface-tools/src',
  # 'C:/Users/Thomas/SourceTree/Argus/src',
  # 'C:/Users/Thomas/SourceTree/sketchup-safe-frames/src',
  # 'C:/Users/Thomas/SourceTree/SketchUp-Units-and-Locale-Helper',
  'C:/Users/Thomas/SourceTree/CitiesSkylines/src',
  # 'C:/Users/Thomas/SourceTree/su_commondialog/examples',
  'C:/Users/Thomas/SourceTree/shadow-texture/src',
  'C:/Users/Thomas/SourceTree/quad-edge/src',
  # 'C:/Users/Thomas/SourceTree/SOSI/src',
  # 'C:/Users/Thomas/SourceTree/HexUI/src',
  'C:/Users/Thomas/SourceTree/ColorAtUv/src',
  'C:/Users/Thomas/SourceTree/transformation-inspector/src',
  # 'C:/Users/Thomas/SourceTree/MakeIt/src',
  'C:/Users/Thomas/SourceTree/milling-tools/src',
  # 'C:/Users/Thomas/SourceTree/component-replacer/src',
  'C:/Users/Thomas/SourceTree/DevCamp2017HtmlDialog/src',
  'C:/Users/Thomas/SourceTree/DevCamp2017Snippets/src',
  'C:/Users/Thomas/SourceTree/bitmap-2-mesh/src',
  'C:/Users/Thomas/SourceTree/TrueBend/src',
  # 'C:/Users/Thomas/SourceTree/vertex-tools/src',
  # 'C:/Users/Thomas/SourceTree/vertex-tools-v1',
  'C:/Users/Thomas/SourceTree/su_colorize/src',
  # 'C:/Users/Thomas/SourceTree/sketchup-ruby-api-tutorials',
  'C:/Users/Thomas/SourceTree/PlaceComponent/src',
  'C:/Users/Thomas/SourceTree/camera-track/src',
  # 'C:/Users/Thomas/SourceTree/error-reporter-client/src',
  'C:/Users/Thomas/SourceTree/error-reporter-client/examples',
]

if !ARGV.empty? && ARGV[0].include?("DevelopmentBuild")
  # TODO: Clean up this kludge! Add extension ID to VS debug build arguments.
  if defined?(VertexToolDevLoader)
    paths << 'C:/Users/Thomas/SourceTree/SUbD/Ruby/src'
  else
    paths << 'C:/Users/Thomas/SourceTree/vertex-tools/src'
  end
else
  paths << 'C:/Users/Thomas/SourceTree/SUbD/Ruby/src'
  paths << 'C:/Users/Thomas/SourceTree/vertex-tools/src'
end

ruby_files = []
for path in paths
  # puts path
  # Check if some paths should be skipped.
  next if skippables.any? { |skippable| path.include?(skippable) }
  # Add to load path...
  # puts path
  $LOAD_PATH << path
  ruby_files_filter = File.join(path, '*.rb')
  ruby_files.concat(Dir.glob(ruby_files_filter).map { |filename|
    File.basename(filename, '.*')
  })
end

for ruby_file in ruby_files
  begin
    require ruby_file
  rescue LoadError
    raise
  end
end

# puts '</ProxyLoad>'
```

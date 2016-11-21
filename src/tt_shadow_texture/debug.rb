#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'


module TT::Plugins::ShadowTexture

  # @note Debug method to reload the plugin.
  #
  # @example
  #   TT::Plugins::ShadowTexture.reload
  #
  # @return [Integer] Number of files reloaded.
  # noinspection RubyGlobalVariableNamingConvention
  def self.reload
    original_verbose = $VERBOSE
    $VERBOSE = nil
    # Core file (this)
    load __FILE__
    # Supporting files
    if defined?(PATH) && File.exist?(PATH)
      x = Dir.glob(File.join(PATH, '**/*.{rb,rbs}')).each { |file|
        # noinspection RubyResolve
        load file
      }
      x.length + 1
    else
      1
    end
  ensure
    $VERBOSE = original_verbose
  end

end # module

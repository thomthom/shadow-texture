#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'


module TT::Plugins::ShadowTexture

  # Load profiling tests.
  profiles_path = File.expand_path(File.join(__dir__, '../../profiling'))
  filter = File.join(profiles_path, 'PR_*.rb')
  Dir.glob(filter) { |filename|
    begin
      # noinspection RubyResolve
      require filename
    rescue LoadError => error
      puts "Failed to load profile: #{File.basename(filename)}"
      puts "  #{error.message}"
    end
  }

  def self.add_profile_menus(menu)
    # Generate menus for profiling tests.
    menu_profile = menu.add_submenu('Profile')
    menu_profile.add_item('List Profile Tests') {
      raise NotImplementedError
    }
    if defined?(Profiling)
      SpeedUp.build_menus(menu_profile, Profiling)
    end
    file_loaded(__FILE__)
  end

end # module TT::Plugins::ShadowTexture

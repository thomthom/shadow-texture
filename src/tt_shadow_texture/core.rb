#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/shadow_render_tool.rb'


module TT::Plugins::ShadowTexture

  ### MENU & TOOLBARS ### ------------------------------------------------------

  unless file_loaded?(__FILE__)
    menu = UI.menu('Plugins')
    menu.add_item('Render Shadow Texture') {
      self.render_shadow
    }

    file_loaded(__FILE__)
  end


  ### MAIN SCRIPT ### ----------------------------------------------------------

  # Constants for Tool.onCancel
  REASON_ESC = 0
  REASON_REACTIVATE = 1
  REASON_UNDO = 2

  # Constants for Sketchup::View.draw_points
  DRAW_OPEN_SQUARE     = 1
  DRAW_FILLED_SQUARE   = 2
  DRAW_PLUS            = 3
  DRAW_CROSS           = 4
  DRAW_STAR            = 5
  DRAW_OPEN_TRIANGLE   = 6
  DRAW_FILLED_TRIANGLE = 7

  # Constants for Geom::BoundingBox.corner
  BB_LEFT_FRONT_BOTTOM  = 0
  BB_RIGHT_FRONT_BOTTOM = 1
  BB_LEFT_BACK_BOTTOM   = 2
  BB_RIGHT_BACK_BOTTOM  = 3
  BB_LEFT_FRONT_TOP     = 4
  BB_RIGHT_FRONT_TOP    = 5
  BB_LEFT_BACK_TOP      = 6
  BB_RIGHT_BACK_TOP     = 7


  def self.render_shadow
    Sketchup.active_model.select_tool(ShadowRenderTool.new)
  #rescue Exception => error
  #  ERROR_REPORTER.handle(error)
  end


  ### DEBUG ### ----------------------------------------------------------------

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

#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/benchmark'
require 'tt_shadow_texture/debug'
require 'tt_shadow_texture/profiling'
require 'tt_shadow_texture/shadow_render_tool'


module TT::Plugins::ShadowTexture

  unless file_loaded?(__FILE__)
    # TODO: Use custom Command class to wrap bitmap/vector icons and error
    # reporter.
    plugins_menu = UI.menu('Plugins')
    menu = plugins_menu.add_submenu('Shadow Texture')
    menu.add_item('Render Shadow Texture') {
      self.render_shadow
    }
    menu.add_separator
    menu.add_item('Analysis Tool') {
      self.analysis_tool
    }
    menu.add_separator
    self.add_profile_menus(menu)
    Benchmarking.add_menus(menu)

    file_loaded(__FILE__)
  end

  def self.render_shadow
    raise NotImplementedError
  end

  def self.analysis_tool
    Sketchup.active_model.select_tool(ShadowRenderTool.new)
  end

end # module

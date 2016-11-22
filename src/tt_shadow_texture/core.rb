#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/debug'
require 'tt_shadow_texture/sample_tool'
require 'tt_shadow_texture/shadow_render_tool'


module TT::Plugins::ShadowTexture

  unless file_loaded?(__FILE__)
    menu = UI.menu('Plugins')
    menu.add_item('Render Shadow Texture') {
      self.render_shadow
    }
    menu.add_item('Render Shadow Samples') {
      self.render_sample
    }

    file_loaded(__FILE__)
  end


  def self.render_shadow
    Sketchup.active_model.select_tool(ShadowRenderTool.new)
  #rescue Exception => error
  #  ERROR_REPORTER.handle(error)
  end

  def self.render_sample
    Sketchup.active_model.select_tool(SampleTool.new)
  end

end # module

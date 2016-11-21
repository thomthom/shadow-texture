#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'tt_shadow_texture/shadow_render.rb'


module TT::Plugins::ShadowTexture

  class ShadowRenderTool

    def activate
      model = Sketchup.active_model
      face = model.selection.grep(Sketchup::Face).first
      @render = ShadowRender.new(face)
      model.active_view.invalidate
    end

    def deactivate(view)
      view.invalidate
    end

    def suspend(view)
      view.invalidate
    end

    def resume(view)
      view.invalidate
    end

    def draw(view)
      @render.draw(view) if @render
    end

  end

end

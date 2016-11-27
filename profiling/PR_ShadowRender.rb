#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'speedup.rb'
require 'testup/testcase'


module TT::Plugins::ShadowTexture
module Profiling

  # noinspection RubyInstanceMethodNamingConvention
  class PR_ShadowRender < SpeedUp::ProfileTest

    include TestUp::SketchUpTestUtilities


    def setup
      @render = ShadowRender.new
      @render.shadow_color = Image::DIB::Color.new('red')

      @model = load_test_model('simple-hex.skp')
      @face = @model.entities.grep(Sketchup::Face).find { |face|
        face.edges.size == 6
      }
    end

    def load_test_model(basename)
      filename = File.expand_path(File.join(__dir__, '../models', basename))
      model = Sketchup.active_model
      return model if File.basename(model.path) == basename
      Sketchup.open_file(filename)
      Sketchup.active_model
    end

    def render_to_face(pixels, sub_samples)
      sampler = ShadowSampler.new(@face, pixels)
      sampler.sub_samples = sub_samples
      @model.start_operation('Render Shadow', true)
      @render.render_to_face(sampler)
      @model.commit_operation
    end


    def profile_render_to_face_8x8x1
      render_to_face(8, 1)
    end

    def profile_render_to_face_8x8x2
      render_to_face(8, 2)
    end

    def profile_render_to_face_32x32x2
      render_to_face(32, 2)
    end

  end # class

end # module
end # module

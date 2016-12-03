#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'benchmark'
require 'sketchup.rb'


module TT::Plugins::ShadowTexture

  module Benchmarking

    # @param [Sketchup::Menu] menu
    def self.add_menus(menu)
      menu.add_item('Simple Hex 8:2') {
        self.benchmark(8, 2)
      }
    end

    # @param [Integer] pixels
    # @param [Integer] sub_samples
    def self.benchmark(pixels, sub_samples)
      face = setup_model
      puts Benchmark.measure {
        self.render_shadow(face, pixels, sub_samples)
      }
    end

    # @param [Sketchup::Face]
    # @param [Integer] pixels
    # @param [Integer] sub_samples
    def self.render_shadow(face, pixels, sub_samples)
      sampler = ShadowSampler.new(face, pixels)
      sampler.sub_samples = sub_samples
      render = ShadowRender.new
      render.shadow_color = Image::DIB::Color.new('red')
      face.model.start_operation('Render Shadow', true)
      render.render_to_face(sampler)
      face.model.commit_operation
    end

    # @return [String]
    def self.project_path
      File.expand_path(File.join(__dir__, '../..'))
    end

    # @return [String]
    def self.models_path
      File.join(self.project_path, 'model')
    end

    # @param [String] basename
    # @return [Sketchup::Model]
    def self.load_model(basename)
      filename = File.join(self.models_path, basename)
      model = Sketchup.active_model
      return model if File.basename(model.path) == basename
      Sketchup.open_file(filename)
      Sketchup.active_model
    end

    # @return [Sketchup::Face]
    def self.setup_model
      model = load_test_model('simple-hex.skp')
      model.entities.grep(Sketchup::Face).find { |face|
        face.edges.size == 6
      }
    end

  end # module

end # module TT::Plugins::ShadowTexture

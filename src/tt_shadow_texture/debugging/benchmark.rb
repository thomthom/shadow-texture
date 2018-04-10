#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'benchmark'


module TT::Plugins::ShadowTexture

  module Benchmarking

    # @param [Sketchup::Menu] menu
    def self.add_menus(menu)
      configs = [
          [ 8, 2, 5],
          [16, 2, 5],
          [32, 2, 5],
      ]
      sub_menu = menu.add_submenu('Benchmark')
      sub_menu.add_item('Run All') {
        self.benchmark_all(configs)
      }
      sub_menu.add_separator
      configs.each { |config|
        sub_menu.add_item("Simple Hex #{config[0]}:#{config[1]}") {
          self.benchmark(*config)
        }
      }
    end

    def self.benchmark_all(configs)
      configs.each { |config|
        self.benchmark(*config)
      }
    end

    # @param [Integer] pixels
    # @param [Integer] sub_samples
    def self.benchmark(pixels, sub_samples, iterations = 5)
      face = self.setup_model
      puts ''
      puts "Benchmark Results (#{pixels} pixels, #{sub_samples} sub-samples):"
      label = "#{pixels}px:#{sub_samples}"
      GC.start
      Benchmark.bm(10) do |bm|
        iterations.times { |i|
          bm.report("#{label} ##{i + 1}") {
            self.render_shadow(face, pixels, sub_samples)
          }
        }
      end
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
      File.expand_path(File.join(__dir__, '../../..'))
    end

    # @return [String]
    def self.models_path
      File.join(self.project_path, 'models')
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
      model = self.load_model('simple-hex.skp')
      model.entities.grep(Sketchup::Face).find { |face|
        face.edges.size == 6
      }
    end

  end # module

end # module TT::Plugins::ShadowTexture

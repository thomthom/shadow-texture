#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/multi_sampler'


module TT::Plugins::ShadowTexture

  class ShadowSampler < MultiSampler

    # @return [Sketchup::Face]
    attr_reader :face

    # @return [Integer] sub-sample subdivisions
    attr_accessor :sub_samples

    # @param [Sketchup::Face] face
    # @param [Integer] pixels width and height of the sampler
    def initialize(face, pixels)
      super(face.bounds, pixels)
      @face = face
      @sub_samples = 2
    end

    def sample(&block)
      super { |pixel, pixel_bounds|
        sampler = MultiSampler.new(pixel_bounds, sub_samples)
        sub_samples = sampler.sample { |sub_point, sub_bounds|
          sample_shadow(sub_point, sub_bounds)
        }
        block.call(sub_samples, pixel_bounds)
      }
    end

    private

    # @return [Sketchup::Model]
    def model
      face.model
    end

    # @return [Geom::Vector3d]
    def shadow_direction
      model.shadow_info['SunDirection']
    end

    # @param [Geom::Point2d] point
    # @param [Bounds2d] bounds
    # @return [Hash]
    def sample_shadow(point, bounds)
      ray = [point, shadow_direction]
      result = model.raytest(ray, true)
      # TODO: Convert to struct.
      {
          source: point,
          target: result ? result.first : nil,
          shadow: !result.nil?,
          bounds: bounds
      }
    end

  end # class

end

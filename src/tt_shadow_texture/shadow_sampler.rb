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

    attr_reader :face
    attr_accessor :sub_samples

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

    def model
      face.model
    end

    def shadow_direction
      model.shadow_info['SunDirection']
    end

    def sample_shadow(point, bounds)
      ray = [point, shadow_direction]
      result = model.raytest(ray, true)
      {
          source: point,
          #target: result ? result.first : Geom.intersect_line_plane(ray, plane),
          target: result ? result.first : nil,
          shadow: !result.nil?,
          bounds: bounds
      }
    end

  end # class

end

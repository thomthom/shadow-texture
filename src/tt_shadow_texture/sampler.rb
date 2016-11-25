#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/bounds2d'


module TT::Plugins::ShadowTexture

  class Sampler

    # @return [Bounds2d]
    attr_reader :bounds

    # @param [Bounds2d, Geom::BoundingBox] bounds
    def initialize(bounds)
      @bounds = Bounds2d.new(bounds)
    end

    def sample(&block)
      block.call(bounds.center, bounds)
    end

  end # class

end

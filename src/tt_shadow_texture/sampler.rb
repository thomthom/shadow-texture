#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/boundingbox'


module TT::Plugins::ShadowTexture

  class Sampler

    include BoundingBoxHelper

    attr_reader :bounds

    def initialize(bounds)
      @bounds = bounds
    end

    def sample(&block)
      block.call(bounds.center, bounds)
    end

  end # class

end

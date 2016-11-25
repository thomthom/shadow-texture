#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'


module TT::Plugins::ShadowTexture

  class UV < Geom::Point3d; end

  class UVMapping

    def initialize
      @mapping = []
    end

    # @param [Geom::Point3d] model_point
    # @param [UV] uv
    # @return [nil]
    def add(model_point, uv)
      @mapping << model_point
      @mapping << uv
      nil
    end

    # @return [Array]
    def to_a
      @mapping
    end

    # @return [Array]
    def to_ary
      @mapping
    end

  end # class

end # module

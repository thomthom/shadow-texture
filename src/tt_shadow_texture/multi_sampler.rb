#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/sampler'


module TT::Plugins::ShadowTexture

  class MultiSampler < Sampler

    # @return [Integer] sample sub-divisions
    attr_accessor :samples

    # @param [Bounds2d] bounds
    # @param [Integer] samples
    def initialize(bounds, samples)
      super(bounds)
      @samples = samples
    end

    def sample(&block)
      row_size = bounds.width / samples.to_f
      col_size = bounds.height / samples.to_f
      sample_points(bounds, row_size, col_size).map { |point|
        sample_bounds = point_to_bounds(point, row_size, col_size)
        block.call(point, sample_bounds)
      }
    end

    private

    # @param [Bounds2d] bounds
    # @param [Integer] row_width
    # @param [Integer] col_width
    # @return [Array<Geom::Point3d>]
    def sample_points(bounds, row_width, col_width)
      offset = Geom::Vector3d.new(row_width / 2, col_width / 2, 0)
      points = []
      samples.times { |y|
        samples.times { |x|
          points << (bounds.min + [x * row_width, y * col_width, 0] + offset)
        }
      }
      points
    end

    # @param [Geom::Point3d] point
    # @param [Integer] width
    # @param [Integer] height
    # @return [Bounds2d]
    def point_to_bounds(point, width, height)
      half_width = width / 2.0
      half_height = height / 2.0
      x1 = point.x - half_width
      y1 = point.y - half_height
      x2 = point.x + half_width
      y2 = point.y + half_height
      bb = Bounds2d.new
      bb.add([x1, y1, 0])
      bb.add([x2, y2, 0])
      bb
    end

  end # class

end

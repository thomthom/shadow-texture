#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/constants/boundingbox'


module TT::Plugins::ShadowTexture

  class Bounds2d < Geom::BoundingBox

    include BoundingBoxConstants

    def initialize(*points_or_bounds)
      super()
      add(*points_or_bounds) unless points_or_bounds.empty?
    end

    # @return [Array<Geom::Point3d>] four points
    def points
      [
          corner(BB_LEFT_FRONT_BOTTOM),
          corner(BB_RIGHT_FRONT_BOTTOM),
          corner(BB_RIGHT_BACK_BOTTOM),
          corner(BB_LEFT_BACK_BOTTOM)
      ]
    end

    # @return [Array<Geom::Point3d>]
    def segments
      [
          corner(BB_LEFT_FRONT_BOTTOM),
          corner(BB_RIGHT_FRONT_BOTTOM),

          corner(BB_RIGHT_FRONT_BOTTOM),
          corner(BB_RIGHT_BACK_BOTTOM),

          corner(BB_RIGHT_BACK_BOTTOM),
          corner(BB_LEFT_BACK_BOTTOM),

          corner(BB_LEFT_BACK_BOTTOM),
          corner(BB_LEFT_FRONT_BOTTOM)
      ]
    end

    # @param [Integer] steps
    # @return [Array<Array(Geom::Point3d, Geom::Point3d)>]
    def grid_segments(steps)
      # Vertical segments.
      left = [
          corner(BB_LEFT_FRONT_BOTTOM),
          corner(BB_LEFT_BACK_BOTTOM)
      ]
      right = [
          corner(BB_RIGHT_FRONT_BOTTOM),
          corner(BB_RIGHT_BACK_BOTTOM)
      ]
      x_lines = interpolate_points(left, right, steps)
      # Horizontal segments.
      front = [
          corner(BB_LEFT_FRONT_BOTTOM),
          corner(BB_RIGHT_FRONT_BOTTOM)
      ]
      bottom = [
          corner(BB_LEFT_BACK_BOTTOM),
          corner(BB_RIGHT_BACK_BOTTOM)
      ]
      y_lines = interpolate_points(front, bottom, steps)
      # Merge to a single array og segments.
      x_lines.concat(y_lines)
    end

    private

    # @param [Array(Geom::Point3d, Geom::Point3d)] segment1
    # @param [Array(Geom::Point3d, Geom::Point3d)] segment2
    # @param [Integer] steps
    # @return [Array<Array(Geom::Point3d, Geom::Point3d)>]
    def interpolate_points(segment1, segment2, steps)
      segments = []
      (1...steps).each { |i|
        w1 = i.to_f / steps.to_f
        w2 = 1.0 - w1
        segments << [
            Geom.linear_combination(w1, segment1[0], w2, segment2[0]),
            Geom.linear_combination(w1, segment1[1], w2, segment2[1])
        ]
      }
      segments
    end

  end # class

end # module

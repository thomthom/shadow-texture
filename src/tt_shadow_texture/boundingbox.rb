#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/constants/boundingbox'
require 'tt_shadow_texture/constants/view'


module TT::Plugins::ShadowTexture

  module BoundingBoxHelper

    include BoundingBoxConstants

    def bounds_top_plane(bounds)
      points = [
          bounds.corner(BB_LEFT_FRONT_TOP),
          bounds.corner(BB_RIGHT_FRONT_TOP),
          bounds.corner(BB_RIGHT_BACK_TOP),
          bounds.corner(BB_LEFT_BACK_TOP)
      ]
      Geom.fit_plane_to_points(points)
    end

    def transform_bounds(bounds, transformation)
      new_bounds = Geom::BoundingBox.new
      new_bounds.add(bounds.min.transform(transformation))
      new_bounds.add(bounds.max.transform(transformation))
      new_bounds
    end

    def bounds_ground_points(bounds)
      [
          bounds.corner(BB_LEFT_FRONT_BOTTOM),
          bounds.corner(BB_RIGHT_FRONT_BOTTOM),
          bounds.corner(BB_RIGHT_BACK_BOTTOM),
          bounds.corner(BB_LEFT_BACK_BOTTOM)
      ]
    end

    def interpolate_points(left, right, steps)
      lines = []
      (1...steps).each { |i|
        w1 = i.to_f / steps.to_f
        w2 = 1.0 - w1
        lines << [
            Geom.linear_combination(w1, left[0], w2, right[0]),
            Geom.linear_combination(w1, left[1], w2, right[1])
        ]
      }
      lines
    end

    def bounds_grid_points(bounds)
      left = [
          bounds.corner(BB_LEFT_FRONT_BOTTOM),
          bounds.corner(BB_LEFT_BACK_BOTTOM)
      ]
      right = [
          bounds.corner(BB_RIGHT_FRONT_BOTTOM),
          bounds.corner(BB_RIGHT_BACK_BOTTOM)
      ]
      x_lines = interpolate_points(left, right, pixel_size)

      front = [
          bounds.corner(BB_LEFT_FRONT_BOTTOM),
          bounds.corner(BB_RIGHT_FRONT_BOTTOM)
      ]
      bottom = [
          bounds.corner(BB_LEFT_BACK_BOTTOM),
          bounds.corner(BB_RIGHT_BACK_BOTTOM)
      ]
      y_lines = interpolate_points(front, bottom, pixel_size)

      x_lines.flatten.concat(y_lines.flatten)
    end

  end # module

end

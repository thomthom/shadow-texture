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

  class ShadowRender

    include BoundingBoxConstants
    include ViewConstants

    attr_reader :face, :pixel_size

    def initialize(face)
      @face = face
      @pixel_size = 8
    end

    #def render
    #end

    def draw(view)
      bounds = overlap_transform(@face.bounds, view)
      draw_bounds(bounds, view)
      draw_bounds_grid(bounds, view)
      #draw_samples(@face.bounds, view)
      draw_shadow_rays(@face.bounds, view)
    end

    private

    def model_top_plane(model)
      bounds = model.bounds
      points = [
        bounds.corner(BB_LEFT_FRONT_TOP),
        bounds.corner(BB_RIGHT_FRONT_TOP),
        bounds.corner(BB_RIGHT_BACK_TOP),
        bounds.corner(BB_LEFT_BACK_TOP)
      ]
      Geom.fit_plane_to_points(points)
    end

    def trace_shadow_rays(points)
      model = Sketchup.active_model
      plane = model_top_plane(model)
      shadow_direction = model.shadow_info['SunDirection']
      points.map { |point|
        ray = [point, shadow_direction]
        result = model.raytest(ray, true)
        {
          source: point,
          #target: result ? result.first : point.offset(shadow_direction, model.bounds.depth),
          target: result ? result.first : Geom.intersect_line_plane(ray, plane),
          shadow: !result.nil?
        }
      }
    end

    def draw_shadow_rays(bounds, view)
      samples_source = samples_points(bounds)

      samples = trace_shadow_rays(samples_source)
      samples_shadow, samples_sun = samples.partition { |sample| sample[:shadow] }

=begin
      points_sun = samples_sun.map { |sample| [sample[:source], sample[:target]] }.flatten
      points_shadow = samples_shadow.map { |sample| [sample[:source], sample[:target]] }.flatten
      view.line_width = 1
      view.line_stipple = '-'
      view.drawing_color = 'orange'
      view.draw(GL_LINES, points_sun)
      view.drawing_color = 'navy'
      view.draw(GL_LINES, points_shadow)
=end

      points_sun = samples_sun.map { |sample| sample[:source] }
      points_shadow = samples_shadow.map { |sample| sample[:source] }
      view.line_width = 2
      view.line_stipple = '2'
      view.draw_points(points_sun, 7, DRAW_PLUS, 'orange') unless points_sun.empty?
      view.draw_points(points_shadow, 7, DRAW_PLUS, 'navy') unless points_shadow.empty?
    end

    def samples_points(bounds)
      x_step = (bounds.width / pixel_size)
      y_step = (bounds.height / pixel_size)
      offset = Geom::Vector3d.new(x_step / 2, y_step / 2, 0)
      points = []
      pixel_size.times { |x|
        pixel_size.times { |y|
          points << (bounds.min + [x * x_step, y * y_step, 0] + offset)
        }
      }
      points
    end

    def draw_samples(bounds, view)
      points = samples_points(bounds)
      view.line_width = 2
      view.line_stipple = ''
      view.draw_points(points, 5, DRAW_CROSS, 'red')
    end

    def overlap_transform(bounds, view)
      distance = view.pixels_to_model(1, bounds.center)
      offset = bounds.center.offset(Z_AXIS, distance)
      vector = bounds.center.vector_to(offset)
      tr = Geom::Transformation.new(vector)
      transform_bounds(bounds, tr)
    end

    def transform_bounds(bounds, transformation)
      new_bounds = Geom::BoundingBox.new
      new_bounds.add(bounds.min.transform(transformation))
      new_bounds.add(bounds.max.transform(transformation))
      new_bounds
    end

    def bounds_points(bounds)
      [
        bounds.corner(BB_LEFT_FRONT_BOTTOM),
        bounds.corner(BB_RIGHT_FRONT_BOTTOM),
        bounds.corner(BB_RIGHT_BACK_BOTTOM),
        bounds.corner(BB_LEFT_BACK_BOTTOM)
      ]
    end

    def draw_bounds(bounds, view)
      points = bounds_points(bounds)
      view.line_width = 2
      view.line_stipple = ''
      view.drawing_color = 'red'
      view.draw(GL_LINE_LOOP, points)
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

    def draw_bounds_grid(bounds, view)
      points = bounds_grid_points(bounds)
      view.line_width = 1
      view.line_stipple = '_'
      view.drawing_color = 'red'
      view.draw(GL_LINES, points)
    end

  end # class

end

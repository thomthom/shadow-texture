#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/constants/boundingbox'
require 'tt_shadow_texture/constants/tool'
require 'tt_shadow_texture/constants/view'
#require 'tt_shadow_texture/shadow_render'
require 'tt_shadow_texture/shadow_sampler'


module TT::Plugins::ShadowTexture

  # noinspection RubyInstanceMethodNamingConvention
  class SampleTool

    include BoundingBoxConstants
    include ViewConstants
    include ToolConstants

    def activate
      model = Sketchup.active_model
      face = model.selection.grep(Sketchup::Face).first
      @sampler = ShadowSampler.new(face, 8)
      update(model.active_view)
    end

    def deactivate(view)
      view.invalidate
    end

    def suspend(view)
      view.invalidate
    end

    def resume(view)
      update(view)
    end

    def enableVCB?
      true
    end

    def onUserText(text, view)
      samples, sub_samples = text.split(';')
      @sampler.samples = samples.to_i unless samples.nil?
      @sampler.sub_samples = sub_samples.to_i unless sub_samples.nil?
      update(view)
    end

    def draw(view)
      draw_samples(@sampler, view)
    end

    private

    def update(view)
      Sketchup.vcb_label = 'Size / Samples'
      Sketchup.vcb_value = "#{@sampler.samples};#{@sampler.sub_samples}"
      view.invalidate
    end

    def draw_samples(sampler, view)
      return if sampler.nil?

      pixel_points = []
      pixel_grid = []

      sun_quads = []
      shadow_quads = []

      sun_points = []
      shadow_points = []

      sampler.sample { |pixel, pixel_bounds|

        pixel_points.concat(bounds_to_gl_lines(pixel_bounds))
        pixel_grid.concat(bounds_grid_points(pixel_bounds, 2))

        pixel.each { |sample|
          quad = bounds_to_gl_line_loop(sample[:bounds])
          if sample[:shadow]
            shadow_points << sample[:source]
            shadow_quads.concat(quad)
          else
            sun_points << sample[:source]
            sun_quads.concat(quad)
          end
        }
      }

      view.line_width = 2
      view.line_stipple = '2'
      view.draw_points(sun_points, 7, DRAW_PLUS, 'orange') unless sun_points.empty?
      view.draw_points(shadow_points, 7, DRAW_PLUS, 'navy') unless shadow_points.empty?

      #draw_quads(sun_quads, Sketchup::Color.new(255, 255, 0, 64), view)
      draw_quads(shadow_quads, Sketchup::Color.new(0, 0, 255, 64), view)

      draw_bounds(pixel_points, view)
      draw_bounds_grid(pixel_grid, view)
    end

    def bounds_to_gl_line_loop(bounds)
      [
          bounds.corner(BB_LEFT_FRONT_BOTTOM),
          bounds.corner(BB_RIGHT_FRONT_BOTTOM),
          bounds.corner(BB_RIGHT_BACK_BOTTOM),
          bounds.corner(BB_LEFT_BACK_BOTTOM)
      ]
    end

    def bounds_to_gl_lines(bounds)
      [
        bounds.corner(BB_LEFT_FRONT_BOTTOM),
        bounds.corner(BB_RIGHT_FRONT_BOTTOM),

        bounds.corner(BB_RIGHT_FRONT_BOTTOM),
        bounds.corner(BB_RIGHT_BACK_BOTTOM),

        bounds.corner(BB_RIGHT_BACK_BOTTOM),
        bounds.corner(BB_LEFT_BACK_BOTTOM),

        bounds.corner(BB_LEFT_BACK_BOTTOM),
        bounds.corner(BB_LEFT_FRONT_BOTTOM)
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

    def bounds_grid_points(bounds, subdivisions)
      left = [
          bounds.corner(BB_LEFT_FRONT_BOTTOM),
          bounds.corner(BB_LEFT_BACK_BOTTOM)
      ]
      right = [
          bounds.corner(BB_RIGHT_FRONT_BOTTOM),
          bounds.corner(BB_RIGHT_BACK_BOTTOM)
      ]
      x_lines = interpolate_points(left, right, subdivisions)

      front = [
          bounds.corner(BB_LEFT_FRONT_BOTTOM),
          bounds.corner(BB_RIGHT_FRONT_BOTTOM)
      ]
      bottom = [
          bounds.corner(BB_LEFT_BACK_BOTTOM),
          bounds.corner(BB_RIGHT_BACK_BOTTOM)
      ]
      y_lines = interpolate_points(front, bottom, subdivisions)

      x_lines.flatten.concat(y_lines.flatten)
    end

    def draw_bounds(points, view)
      view.line_width = 2
      view.line_stipple = ''
      view.drawing_color = 'red'
      view.draw(GL_LINES, points)
    end

    def draw_bounds_grid(points, view)
      view.line_width = 1
      view.line_stipple = '_'
      view.drawing_color = 'red'
      view.draw(GL_LINES, points)
    end

    def draw_quads(points, color, view)
      view.drawing_color = color
      view.draw(GL_QUADS, points)
    end

  end

end

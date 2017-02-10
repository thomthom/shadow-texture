#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'tt_shadow_texture/drawing_helper'
require 'tt_shadow_texture/shadow_render'
require 'tt_shadow_texture/shadow_sampler'


module TT::Plugins::ShadowTexture

  # noinspection RubyInstanceMethodNamingConvention
  class ShadowRenderTool

    include DrawingHelper

    attr_reader :options

    def initialize
      # Created on demand.
      # TODO: This is really a transient worker class. Need to cache it's result
      # and use that to draw and render. Then there is no need for this instance
      # variable.
      @sampler = nil

      @render = ShadowRender.new
      @render.shadow_color = Image::DIB::Color.new('blue')

      @options = {
          draw_local: false,
          draw_shadows: true,
          draw_pixel_grid: true,
          draw_sample_grid: true,
          draw_sample_point: true,
          draw_shadow_sample: false,
      }
    end

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

    def onLButtonUp(_flags, _x, _y, view)
      view.model.start_operation('Render Shadow', true)
      @render.render_to_face(@sampler)
      view.model.commit_operation
    end

    def onUserText(text, view)
      samples, sub_samples = text.split(';')
      @sampler.samples = samples.to_i unless samples.nil?
      @sampler.sub_samples = sub_samples.to_i unless sub_samples.nil?
      update(view)
    end

    def draw(view)
      draw_sampler(@sampler, view)
    end

    # @param [Sketchup::Menu] menu
    def getMenu(menu)
      add_option_menu(menu, :draw_shadows, 'Draw Shadows')
      menu.add_separator
      add_option_menu(menu, :draw_sample_point, 'Draw Sample Points')
      menu.add_separator
      add_option_menu(menu, :draw_pixel_grid, 'Draw Pixel Grid')
      menu.add_separator
      add_option_menu(menu, :draw_sample_grid, 'Draw Sub-Pixel Grid')
      add_option_menu(menu, :draw_shadow_sample, 'Draw Sub-Pixel Shadows')
      menu.add_separator
      add_option_menu(menu, :draw_local, 'Draw Local')
    end

    private

    # @param [Sketchup::Menu] menu
    # @param [Symbol] key
    # @param [String] title
    # @return [Integer] menu id
    def add_option_menu(menu, key, title)
      menu_id = menu.add_item(title) {
        options[key] = !options[key]
        update(Sketchup.active_model.active_view)
      }
      menu.set_validation_proc(menu_id) {
        options[key] ? MF_CHECKED : MF_ENABLED
      }
      menu_id
    end

    # @param [Sketchup::View] view
    def update(view)
      Sketchup.vcb_label = 'Size / Samples'
      Sketchup.vcb_value = "#{@sampler.samples};#{@sampler.sub_samples}"
      view.invalidate
    end

    def draw_sample_shadows?
      options[:draw_shadow_sample]
    end

    def draw_pixel_shadows?
      !draw_sample_shadows?
    end

    def draw_sample_points?
      options[:draw_sample_point]
    end

    # @param [ShadowSampler] sampler
    # @param [Sketchup::View] view
    def draw_sampler(sampler, view)
      return if sampler.nil?

      pixel_points = []
      pixel_grid = []

      shadow_quads = {
          255 => []
      }

      sun_points = []
      shadow_points = []

      sampler.sample { |pixel, pixel_bounds|

        if options[:draw_pixel_grid]
          points = pixel_bounds.segments
          pixel_points.concat(points)
        end

        if options[:draw_sample_grid]
          points = pixel_bounds.grid_segments(2).flatten
          pixel_grid.concat(points)
        end

        pixel.each { |sample|
          if sample[:shadow]
            shadow_points << sample[:source] if draw_sample_points?
            if draw_sample_shadows?
              quad = sample[:bounds].points
              shadow_quads[255].concat(quad)
            end
          else
            sun_points << sample[:source] if draw_sample_points?
          end
        }

        if draw_pixel_shadows?
          quad = pixel_bounds.points
          weight = pixel.count { |sample| sample[:shadow] } / pixel.size.to_f
          alpha = (255 * weight).to_i.abs
          shadow_quads[alpha] ||= []
          shadow_quads[alpha].concat(quad)
        end
      }

      shadow_quads.each { |alpha, quads|
        draw_quads(tr(quads), Sketchup::Color.new(0, 0, 255, alpha), view)
      } if options[:draw_shadows]

      draw_samples(tr(sun_points), 'orange', view)
      draw_samples(tr(shadow_points), 'purple', view)

      draw_bounds(tr(lift(pixel_points, view)), view)
      draw_bounds_grid(tr(lift(pixel_grid, view)), view)

      points = local_face_points(sampler)
      draw_polygon(lift(points, view, DRAW_LEVEL2), 'purple', view)
    end

    # @param [ShadowSampler] sampler
    def local_face_points(sampler)
      sampler.face.outer_loop.vertices.map { |vertex|
        vertex.position.transform(sampler.to_local)
      }
    end

    # @param [Array<Geom::Point3d>] points
    # @return [Array<Geom::Point3d>]
    def tr(points)
      if options[:draw_local]
        points
      else
        points.map { |point| point.transform(@sampler.to_world) }
      end
    end

    # @param [Array<Geom::Point3d>] points
    # @param [Sketchup::View] view
    def draw_bounds(points, view)
      view.line_width = 2
      view.line_stipple = ''
      view.drawing_color = 'red'
      view.draw(GL_LINES, points) unless points.empty?
    end

    # @param [Array<Geom::Point3d>] points
    # @param [Sketchup::View] view
    def draw_bounds_grid(points, view)
      view.line_width = 1
      view.line_stipple = '_'
      view.drawing_color = 'red'
      view.draw(GL_LINES, points) unless points.empty?
    end

    # @param [Array<Geom::Point3d>] points
    # @param [Sketchup::Color] color
    # @param [Sketchup::View] view
    def draw_quads(points, color, view)
      view.drawing_color = color
      view.draw(GL_QUADS, points) unless points.empty?
    end

    # @param [Array<Geom::Point3d>] points
    # @param [Sketchup::Color] color
    # @param [Sketchup::View] view
    def draw_polygon(points, color, view)
      view.line_width = 2
      view.line_stipple = ''
      view.drawing_color = color
      view.draw(GL_LINE_LOOP, points) unless points.empty?
    end

    # @param [Array<Geom::Point3d>] points
    # @param [Sketchup::Color] color
    # @param [Sketchup::View] view
    def draw_samples(points, color, view)
      view.line_width = 2
      view.line_stipple = ''
      view.draw_points(points, 7, DRAW_PLUS, color) unless points.empty?
    end

  end # class

end # module

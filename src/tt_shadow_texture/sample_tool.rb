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
require 'tt_shadow_texture/image/bmp'
require 'tt_shadow_texture/shadow_sampler'


module TT::Plugins::ShadowTexture

  # noinspection RubyInstanceMethodNamingConvention
  class SampleTool

    include BoundingBoxConstants
    include ViewConstants
    include ToolConstants

    attr_reader :options

    def initialize
      @options = {
          draw_shadows: true,
          draw_pixel_grid: true,
          draw_sample_grid: true,
          draw_shadow_sample: false,
          draw_sample_point: true,
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
      render_shadows(@sampler)
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

    def getMenu(menu)
      add_option_menu(menu, :draw_shadows, 'Draw Shadows')
      menu.add_separator
      add_option_menu(menu, :draw_sample_point, 'Draw Sample Points')
      menu.add_separator
      add_option_menu(menu, :draw_pixel_grid, 'Draw Pixel Grid')
      menu.add_separator
      add_option_menu(menu, :draw_sample_grid, 'Draw Sub-Pixel Grid')
      add_option_menu(menu, :draw_shadow_sample, 'Draw Sub-Pixel Shadows')
    end

    private

    def add_option_menu(menu, key, title)
      menu_id = menu.add_item(title) {
        options[key] = !options[key]
        update(Sketchup.active_model.active_view)
      }
      menu.set_validation_proc(menu_id) {
        options[key] ? MF_CHECKED : MF_ENABLED
      }
    end

    def update(view)
      Sketchup.vcb_label = 'Size / Samples'
      Sketchup.vcb_value = "#{@sampler.samples};#{@sampler.sub_samples}"
      view.invalidate
    end

    def render_shadows(sampler)
      size = sampler.samples
      bitspp = 24
      background_color = Image::DIB::Color.new('white')
      shadow_color = Image::DIB::Color.new('blue')
      image = Image::BMP.new(size, size, bitspp, background_color)
      # Render shadow to bitmap.
      i = 0 # TODO: Get rid of silly manual index increment.
      sampler.sample { |pixel|
        weight = pixel.count { |sample| sample[:shadow] } / pixel.size.to_f
        # If weight = 0, you will get color2. If weight = 1 you will get color1.
        color = shadow_color.blend(background_color, weight)
        image.set(i, color)
        i += 1
      }
      # Save to temp file and load into material.
      temp = File.join(Sketchup.temp_dir, "tt_shadow_#{Time.now.to_i}.bmp")
      begin
        image.save(temp)
        face = sampler.face
        model = face.model
        material = face.material || model.materials.add("shadow_#{face.entityID}")
        material.texture = temp
      ensure
        File.delete(temp) if File.exist?(temp)
      end
      # Ensure it's positioned correctly on face
      points = bounds_to_gl_line_loop(sampler.bounds)
      mapping = [
          points[0],
          Geom::Point3d.new(0, 0, 0),

          points[1],
          Geom::Point3d.new(1, 0, 0),

          points[2],
          Geom::Point3d.new(1, 1, 0),

          points[3],
          Geom::Point3d.new(0, 1, 0),
      ]
      face.position_material(material, mapping, true)
    end

    def draw_sample_shadows?
      options[:draw_shadow_sample]
    end

    def draw_pixel_shadows?
      !draw_sample_shadows?
    end

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
          pixel_points.concat(bounds_to_gl_lines(pixel_bounds))
        end

        if options[:draw_sample_grid]
          pixel_grid.concat(bounds_grid_points(pixel_bounds, 2))
        end

        pixel.each { |sample|
          if sample[:shadow]
            shadow_points << sample[:source] if options[:draw_sample_point]
            if draw_sample_shadows?
              quad = bounds_to_gl_line_loop(sample[:bounds])
              shadow_quads[255].concat(quad) if draw_sample_shadows?
            end
          else
            sun_points << sample[:source] if options[:draw_sample_point]
          end
        }

        if draw_pixel_shadows?
          quad = bounds_to_gl_line_loop(pixel_bounds)
          weight = pixel.count { |sample| sample[:shadow] } / pixel.size.to_f
          alpha = (255 * weight).to_i.abs
          shadow_quads[alpha] ||= []
          shadow_quads[alpha].concat(quad)
        end
      }

      shadow_quads.each { |alpha, quads|
        draw_quads(quads, Sketchup::Color.new(0, 0, 255, alpha), view)
      } if options[:draw_shadows]

      draw_samples(sun_points, 'orange', view)
      draw_samples(shadow_points, 'purple', view)

      draw_bounds(lift(pixel_points), view)
      draw_bounds_grid(lift(pixel_grid), view)
    end

    LEVEL1 = 1.0
    LEVEL2 = 2.0
    LEVEL3 = 3.0

    def lift(points, pixel_amount = LEVEL1, direction = Z_AXIS)
      return points if points.empty?
      view = Sketchup.active_model.active_view
      amount = view.pixels_to_model(pixel_amount, points.first)
      offset = direction.clone
      offset.length = amount
      tr = Geom::Transformation.new(offset)
      points.map { |point| point.transform(tr) }
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

    def draw_samples(points, color, view)
      view.line_width = 2
      view.line_stipple = ''
      view.draw_points(points, 7, DRAW_PLUS, color) unless points.empty?
    end

    def draw_bounds(points, view)
      view.line_width = 2
      view.line_stipple = ''
      view.drawing_color = 'red'
      view.draw(GL_LINES, points) unless points.empty?
    end

    def draw_bounds_grid(points, view)
      view.line_width = 1
      view.line_stipple = '_'
      view.drawing_color = 'red'
      view.draw(GL_LINES, points) unless points.empty?
    end

    def draw_quads(points, color, view)
      view.drawing_color = color
      view.draw(GL_QUADS, points) unless points.empty?
    end

  end

end

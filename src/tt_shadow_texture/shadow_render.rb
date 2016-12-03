#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/image/bmp'
require 'tt_shadow_texture/image/dib'
require 'tt_shadow_texture/uv_mapping'
require 'tt_shadow_texture/shadow_sampler'


module TT::Plugins::ShadowTexture

  class ShadowRender

    attr_accessor :background_color, :shadow_color

    BITS_PER_PIXEL = 24

    def initialize
      @background_color = Image::DIB::Color.new('white')
      @shadow_color = Image::DIB::Color.new('black')
    end

    # @param [ShadowSampler] sampler
    # @return [Image::BMP]
    def render_to_bitmap(sampler)
      size = sampler.samples
      image = Image::BMP.new(size, size, BITS_PER_PIXEL, background_color)
      i = 0 # TODO: Get rid of silly manual index increment.
      sampler.sample { |pixel|
        weight = pixel.count { |sample| sample[:shadow] } / pixel.size.to_f
        # If weight = 0, you will get color2. If weight = 1 you will get color1.
        color = shadow_color.blend(background_color, weight)
        image.set(i, color)
        i += 1
      }
      image
    end

    # @param [ShadowSampler] sampler
    # @return [Sketchup::Face]
    def render_to_face(sampler)
      image = render_to_bitmap(sampler)
      material = write_to_material(sampler.face, image)
      map_to_face(sampler, material)
    end

    private

    # @param [Sketchup::Face] face
    # @param [Image::DIB] image
    # @return [Sketchup::Material]
    def write_to_material(face, image)
      temp = File.join(Sketchup.temp_dir, "tt_shadow_#{Time.now.to_i}.bmp")
      begin
        image.save(temp)
        materials = face.model.materials
        material_name = "shadow_#{face.entityID}"
        material = materials[material_name] || materials.add(material_name)
        material.texture = temp
      ensure
        File.delete(temp) if File.exist?(temp)
      end
      material
    end

    # @param [ShadowSampler] sampler
    # @param [Sketchup::Material] material
    # @return [Sketchup::Face]
    def map_to_face(sampler, material)
      points = sampler.bounds.points.map { |point|
        point.transform(sampler.to_world)
      }
      mapping = UVMapping.new
      mapping.add(points[0], UV.new(0, 0))
      mapping.add(points[1], UV.new(1, 0))
      mapping.add(points[2], UV.new(1, 1))
      mapping.add(points[3], UV.new(0, 1))
      sampler.face.position_material(material, mapping.to_a, true)
      sampler.face
    end

  end # class

end # module

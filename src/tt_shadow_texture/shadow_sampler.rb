#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'tt_shadow_texture/multi_sampler'


module TT::Plugins::ShadowTexture

  class ShadowSampler < MultiSampler

    # @return [Sketchup::Face]
    attr_reader :face

    # @return [Geom::Transformation]
    attr_reader :to_local

    # @return [Geom::Transformation]
    attr_reader :to_world

    # @return [Integer] sub-sample subdivisions
    attr_accessor :sub_samples

    # @param [Sketchup::Face] face
    # @param [Integer] pixels width and height of the sampler
    def initialize(face, pixels)
      @to_local, @to_world = face_transformations(face)
      super(local_bounds(face), pixels)
      @face = face
      @sub_samples = 2
    end

    def sample(&block)
      model = face.model
      shadow_direction = model.shadow_info['SunDirection']
      # TODO: Clean up the parent method which return a pixel argument that
      # isn't used here.
      super { |_pixel, pixel_bounds|
        sampler = MultiSampler.new(pixel_bounds, sub_samples)
        sub_samples = sampler.sample { |sub_point, sub_bounds|
          sample_shadow(model, sub_point, sub_bounds, shadow_direction)
        }
        block.call(sub_samples, pixel_bounds)
      }
    end

    private

    # @param [Sketchup::Face] face
    # @return [Bounds2d]
    def local_bounds(face)
      points = face.outer_loop.vertices.map { |vertex|
        vertex.position.transform(@to_local)
      }
      Bounds2d.new(points)
    end

    # @param [Sketchup::Face] face
    # @return [Array(Geom::Transformation, Geom::Transformation)]
    def face_transformations(face)
      # TODO: Infer the general orientation of the face. For example a rectangle
      # or hex off-axis from the world axes. (Like FredoScale)
      to_world = Geom::Transformation.new(face.bounds.center, face.normal)
      to_local = to_world.inverse
      [to_local, to_world]
    end

    # @param [Geom::Point2d] point
    # @param [Bounds2d] bounds
    # @return [Hash]
    def sample_shadow(model, point, bounds, shadow_direction)
      world_point = point.transform(@to_world)
      ray = [world_point, shadow_direction]
      result = model.raytest(ray, true)
      # TODO: Convert to struct.
      {
          source: point,
          target: result ? result.first : nil,
          shadow: !result.nil?,
          bounds: bounds,
      }
    end

  end # class

end

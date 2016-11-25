#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'sketchup.rb'
require 'tt_shadow_texture/constants/tool'
require 'tt_shadow_texture/constants/view'


module TT::Plugins::ShadowTexture

  module DrawingHelper

    include ViewConstants
    include ToolConstants

    DRAW_LEVEL1 = 1.0
    DRAW_LEVEL2 = 2.0
    DRAW_LEVEL3 = 3.0

    # @param [Array<Geom::Point3d>] points
    # @param [Sketchup::View] view
    # @param [Integer] pixel_amount
    # @param [Geom::Vector3d] direction
    # @return [Array<Geom::Point3d>]
    def lift(points, view, pixel_amount = DRAW_LEVEL1, direction = Z_AXIS)
      return points if points.empty?
      amount = view.pixels_to_model(pixel_amount, points.first)
      offset = direction.clone
      offset.length = amount
      tr = Geom::Transformation.new(offset)
      points.map { |point| point.transform(tr) }
    end

  end # class

end # module

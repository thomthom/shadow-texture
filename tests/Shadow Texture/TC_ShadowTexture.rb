#-------------------------------------------------------------------------------
#
# Thomas Thomassen
# thomas[at]thomthom[dot]net
#
#-------------------------------------------------------------------------------

require 'testup/testcase'


class TC_ShadowTexture < TestUp::TestCase

  ShadowTexture = TT::Plugins::ShadowTexture

  def setup
    @render = ShadowTexture::ShadowRender.new
    @render.shadow_color = ShadowTexture::Image::DIB::Color.new('red')

    @model = load_test_model('simple-hex.skp')
    @face = @model.entities.grep(Sketchup::Face).find { |face|
      face.edges.size == 6
    }
    @face.material = nil
  end

  def teardown
    # ...
  end


  # @param [String] basename
  # @return [Sketchup::Model]
  def load_test_model(basename)
    filename = File.expand_path(File.join(__dir__, '../../models', basename))
    model = Sketchup.active_model
    return model if File.basename(model.path) == basename
    Sketchup.open_file(filename)
    Sketchup.active_model
  end

  # @param [Integer] pixels
  # @param [Integer] sub_samples
  # @return [TT::Plugins::ShadowTexture::ShadowSampler]
  def create_sampler(pixels, sub_samples)
    sampler = ShadowTexture::ShadowSampler.new(@face, pixels)
    sampler.sub_samples = sub_samples
    sampler
  end

  # @param [Integer] pixels
  # @param [Integer] sub_samples
  # @return [TT::Plugins::ShadowTexture::Image::BMP]
  def render_to_bitmap(pixels, sub_samples)
    sampler = create_sampler(pixels, sub_samples)
    @model.start_operation('Render Shadow', true)
    image = @render.render_to_bitmap(sampler)
    @model.commit_operation
    image
  end

  # @param [Integer] pixels
  # @param [Integer] sub_samples
  # @return [Sketchup::Face]
  def render_to_face(pixels, sub_samples)
    sampler = create_sampler(pixels, sub_samples)
    @model.start_operation('Render Shadow', true)
    face = @render.render_to_face(sampler)
    @model.commit_operation
    face
  end

  # @param [Array<Integer>]
  # @return [Array<Array(Integer, Integer, Integer)>]
  def expected_data(mask)
    mask.map { |byte| [255, byte, byte] }
  end

  # @param [Array<TT::Plugins::ShadowTexture::Image::DIB::Color>]
  # @return [Array<Array(Integer, Integer, Integer)>]
  def colors_to_arrays(colors)
    colors.map { |color| color.to_a[0..2] }
  end


  # ========================================================================== #
  # method ShadowRender.render_to_bitmap

  DATA_8X8X1 = [
        0,   0, 255, 255, 255, 255, 255, 255,
        0,   0,   0, 255, 255, 255, 255, 255,
        0,   0,   0, 255, 255, 255, 255, 255,
        0,   0,   0, 255, 255, 255, 255, 255,
        0,   0,   0,   0, 255, 255, 255, 255,
        0,   0,   0,   0, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255
  ].freeze

  def test_render_to_bitmap_8x8x1
    image = render_to_bitmap(8, 1)
    assert_kind_of(ShadowTexture::Image::BMP, image)
    assert_equal(8, image.width)
    assert_equal(8, image.height)
    assert_equal(expected_data(DATA_8X8X1), colors_to_arrays(image.data))
  end

  DATA_8X8X2 = [
        0,   0, 191, 255, 255, 255, 255, 255,
        0,   0,   0, 255, 255, 255, 255, 255,
        0,   0,   0, 255, 255, 255, 255, 255,
        0,   0,   0, 191, 255, 255, 255, 255,
        0,   0,   0,   0, 255, 255, 255, 255,
       63,   0,   0,   0, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255,
  ].freeze

  def test_render_to_bitmap_8x8x2
    image = render_to_bitmap(8, 2)
    assert_kind_of(ShadowTexture::Image::BMP, image)
    assert_equal(8, image.width)
    assert_equal(8, image.height)
    assert_equal(expected_data(DATA_8X8X2), colors_to_arrays(image.data))
  end

  DATA_8X8X4 = [
       63,  63, 175, 255, 255, 255, 255, 255,
        0,   0,  15, 255, 255, 255, 255, 255,
        0,   0,   0, 255, 255, 255, 255, 255,
        0,   0,   0, 159, 255, 255, 255, 255,
        0,   0,   0,   0, 255, 255, 255, 255,
       95,   0,   0,   0, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255,
      255, 255, 255, 255, 255, 255, 255, 255,
  ].freeze

  def test_render_to_bitmap_8x8x4
    image = render_to_bitmap(8, 4)
    assert_kind_of(ShadowTexture::Image::BMP, image)
    assert_equal(8, image.width)
    assert_equal(8, image.height)
    assert_equal(expected_data(DATA_8X8X4), colors_to_arrays(image.data))
  end

  def test_render_to_bitmap_16x16x1
    image = render_to_bitmap(16, 1)
    assert_kind_of(ShadowTexture::Image::BMP, image)
    assert_equal(16, image.width)
    assert_equal(16, image.height)
  end


  # ========================================================================== #
  # method ShadowRender.render_to_face

  def test_render_to_face_8x8x1
    face = render_to_face(8, 1)
    assert_kind_of(Sketchup::Face, face)
    assert_equal(@face, face)
    assert_kind_of(Sketchup::Material, face.material)
  end


end # class

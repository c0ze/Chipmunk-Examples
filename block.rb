# The falling object, just called block, but can be anything really
class Block

  attr_accessor :body, :shape

  def initialize(window, size = 2.0)
    @window = window
    @color = Gosu::Color::BLACK

    @box_size = size

    init_body_shape
  end

  def init_body_shape
    @body = CP::Body.new(50, 100)
    @body.p = CP::Vec2.new(250 + rand(SCREEN_WIDTH - 500), -50)
    @body.v = CP::Vec2.new(0,0)
    @body.a = (3 * Math::PI / 2.0)

    @shape_verts = [
                    CP::Vec2.new(-@box_size, @box_size),
                    CP::Vec2.new(@box_size, @box_size),
                    CP::Vec2.new(@box_size, -@box_size),
                    CP::Vec2.new(-@box_size, -@box_size),
                   ]

    @shape = CP::Shape::Poly.new(@body,
                                 @shape_verts,
                                 CP::Vec2.new(0,0))

    @shape.e = 0.5
    @shape.u = 1

    @window.space.add_body(@body)
    @window.space.add_shape(@shape)
  end

  def update
    if @body.p.y > SCREEN_HEIGHT
      @window.space.remove_body(@body)
      @window.space.remove_shape(@shape)
      init_body_shape
    end
  end

  def draw

    top_left, top_right, bottom_left, bottom_right = self.rotate
    @window.draw_quad(top_left.x, top_left.y, @color,
                      top_right.x, top_right.y, @color,
                      bottom_left.x, bottom_left.y, @color,
                      bottom_right.x, bottom_right.y, @color,
                      2)
  end

  def rotate
     half_diagonal = Math.sqrt(2) * (@box_size)
     [-45, +45, -135, +135].collect do |angle|
       CP::Vec2.new(@body.p.x + Gosu::offset_x(@body.a.radians_to_gosu + angle,
                                               half_diagonal),

                    @body.p.y + Gosu::offset_y(@body.a.radians_to_gosu + angle,
                                               half_diagonal))
    end
  end

end

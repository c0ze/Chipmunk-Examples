# I wrote this to help understand the basics of Chipmunk 2D physics
# It has been loosely based on Leonards Boiko's Falling Blocks Tutorial


# Me, Phil Cooper-King
#     Email: <phil@cooperking.net>
#     Website: http://www.mootgames.com

# Gosu:
#     Homepage: http://libgosu.org/
#     Google Code: http://code.google.com/p/gosu/

# Chipmunk:
#     Homepage: http://wiki.slembcke.net/main/published/Chipmunk

# Leonardo Boiko
#     Email: <leoboiko@gmail.com>

# This simply simulates an object falling to the ground


# This requires gosu gem has been installed and the chipmunk bundle.
# The mac version of chipmunk has come with this package.
# For Linux and Windows you'll need to build the package yourself

require 'gosu'
require 'chipmunk'
require 'pry'

require_relative 'numeric'
require_relative 'block'

# These are some general constants
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
FULLSCREEN = false
INFINITY = 1.0/0


# The floor in which the block(s) bounce off
class Floor

  attr_reader :a, :b

  PADDING = 50   # how far the floor is from the sides of the screen

  def initialize(window)
    @window = window
    @color = Gosu::Color::BLACK

    @a = CP::Vec2.new(0,0)
    @b = CP::Vec2.new(SCREEN_WIDTH - (PADDING * 2), 0)

    # CHIPMUNK BODY
    @body = CP::Body.new(INFINITY, INFINITY)
    @body.p = CP::Vec2.new(PADDING, SCREEN_HEIGHT - PADDING)
    @body.v = CP::Vec2.new(0, 0)

    # CHIPMUNK SHAPE
    @shape = CP::Shape::Segment.new(@body,
                                    @a,
                                    @b,
                                    1)
    @shape.e = 0
    @shape.u = 1

    # STATIC SO THAT THE GRAVITY OF THE SPACE DOESN'T HAVE ITS WAY
    @window.space.add_static_shape(@shape)

  end

  def draw
    @window.draw_line(@body.p.x + a.x, @body.p.y + a.y, @color,
                      @body.p.x + b.x, @body.p.y + b.y, @color,
                      1)
  end

end

# These are the falling Blocks
class FallingBlock < Block

  @box_size = 10

  def initialize(window, size = 10)
    @window = window
    @color = Gosu::Color::BLACK

    @box_size = size
    @body = CP::Body.new(10, 100)
    @body.p = CP::Vec2.new(Floor::PADDING + rand(SCREEN_WIDTH - (Floor::PADDING * 2)), rand(50))
    @body.v = CP::Vec2.new(0,0)
    @body.a = (3 * Math::PI / 2.5)

    @shape_verts = [
                    CP::Vec2.new(-@box_size, @box_size),
                    CP::Vec2.new(@box_size, @box_size),
                    CP::Vec2.new(@box_size, -@box_size),
                    CP::Vec2.new(-@box_size, -@box_size),
                   ]

    @shape = CP::Shape::Poly.new(@body,
                                 @shape_verts,
                                 CP::Vec2.new(0,0))

    @shape.e = 0
    @shape.u = 1

    # WE ADD THE THE BODY AND SHAPE TO THE SPACE WHICH THEY WILL LIVE IN
    @window.space.add_body(@body)
    @window.space.add_shape(@shape)
  end

  def update
  end
end

class Game < Gosu::Window

  attr_accessor :space

  SUBSTEPS = 10

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, FULLSCREEN)

    @colors = {:white => Gosu::Color::WHITE, :gray => Gosu::Color::GRAY}
    @dt = (1.0/60.0)

    # CHIPMUNK SPACE, THIS IS THE SPACE WHERE THE BOXES AND FLOOR WILL LIVE IN
    @space = CP::Space.new
    # SETTING A SIMPLE GRAVITY
    @space.gravity = CP::Vec2.new(0, 10)

    # THESE ARE THE OBJECTS WE ARE PLAYING WITH
    @floor = Floor.new(self)
    @blocks = []
    150.times do
      @blocks << FallingBlock.new(self)
    end

  end

  def update
    # THE SUBSTEPS ENSURE THAT THE PHYSICS DOESNT MISS A STEP
    SUBSTEPS.times do
      @blocks.each do |b|
        # WE RESET THE FORCES BECAUSE THE WILL ACCUMULATE OVER THE SUBSTEPS OTHERWISE
        b.shape.body.reset_forces
      end
      @space.step(@dt)
    end
  end

  def draw
    # DRAW THE FLOOR AND THE BLOCKS
    @floor.draw
    @blocks.each do |b|
      b.draw
    end


    # Background Gradient
    self.draw_quad(0, 0, @colors[:white],
                   SCREEN_WIDTH, 0, @colors[:white],
                   0, SCREEN_HEIGHT, @colors[:gray],
                   SCREEN_WIDTH, SCREEN_HEIGHT, @colors[:gray],
                   0)
  end

  # Quit the prog
  def button_down(id)
    if id == Gosu::Button::KbEscape
      close
    end
  end

end

Game.new.show

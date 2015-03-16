# I wrote this to help understand the basics of Chipmunk 2D physics
# If you find anything wrong or disagree with something, please let me know.

# Me, Phil Cooper-King
#     Email: <phil@cooperking.net>
#     Website: http://www.mootgames.com

# Gosu:
#     Homepage: http://libgosu.org/
#     Google Code: http://code.google.com/p/gosu/

# Chipmunk:
#     Homepage: http://wiki.slembcke.net/main/published/Chipmunk

# This simply simulates an object falling and bouncing off slides.


# This requires gosu gem has been installed and the chipmunk bundle.
# The mac version of chipmunk has come with this package.
# For Linux and Windows you'll need to build the package yourself

require 'gosu'
require 'chipmunk'

require_relative 'numeric'
require_relative 'block'

# These are some general constants
SCREEN_WIDTH = 600
SCREEN_HEIGHT = 800
FULLSCREEN = false
INFINITY = 1.0/0

# Generates the Walls for the objects to bounce off
class Wall

  attr_reader :a, :b

  def initialize(window, shape, pos)
    @window = window

    @color = Gosu::Color::BLACK

    @a = CP::Vec2.new(shape[0][0], shape[0][1])
    @b = CP::Vec2.new(shape[1][0], shape[1][1])

    @body = CP::Body.new(INFINITY, INFINITY)
    @body.p = CP::Vec2.new(pos[0], pos[1])
    @body.v = CP::Vec2.new(0,0)

    @shape = CP::Shape::Segment.new(@body, @a, @b, 1)
    @shape.e = 0.5
    @shape.u = 1

    @window.space.add_static_shape(@shape)
  end

  def draw
    @window.draw_line(@body.p.x + a.x, @body.p.y + a.y, @color,
                      @body.p.x + b.x, @body.p.y + b.y, @color,
                      1)
  end

end

class Game < Gosu::Window

  attr_accessor :space

  SUBSTEPS = 10

  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, FULLSCREEN)
    self.caption = "Slides"
    @colors = {:white => Gosu::Color::WHITE, :gray => Gosu::Color::GRAY}

    @dt = (1.0/60.0)

    # CHIPMUNK SPACE
    @space = CP::Space.new
    @space.gravity = CP::Vec2.new(0, 10)

    # This are the four slides.
    @walls = []
    @walls << Wall.new(self, [[0, 0], [200, 200]], [100, 0])
    @walls << Wall.new(self, [[SCREEN_WIDTH, 0], [400, 200]], [-100, 50])
    @walls << Wall.new(self, [[0, 0], [200, 200]], [100, 200])
    @walls << Wall.new(self, [[SCREEN_WIDTH, 0], [400, 200]], [-100, 450])

    @blocks = []
    @max_blocks = 200 # REDUCE THIS IF YOUR SYSTEM IS STRUGGLING
    @current_blocks = 0
    @last_block = Gosu::milliseconds

  end

  def update
    # SUBSTEPS ENSURE THAT IF A BLOCK IS TRAVELING TO FAST OR ITS TO SMALL, IT WONT PASS THROUGH THE WALLS
    # ITS IS'NT REALLY NEEDED HERE, UNLESS YOU START PLAYING AROUND WITH THE SIZES OF THE BLOCKS OR OTHER SETTINGS
    SUBSTEPS.times do
      @blocks.each do |b|
        b.shape.body.reset_forces
      end
      @space.step(@dt)
    end

    # This is a check to see if the block has fallen off the end of the screen, if it has it will be reset.
    @blocks.each do |b|
      b.update
    end

    # This is so that that not all the blocks spawn at once. 
    if (@last_block <= Gosu::milliseconds) && (@current_blocks <= @max_blocks)
      @blocks << Block.new(self)
      @current_blocks += 1
      @last_block += 50
    end

  end

  def draw
    @walls.each do |w|
      w.draw
    end

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

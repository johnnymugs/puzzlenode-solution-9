class LogoGrid

  def initialize(x_bounds, y_bounds)
    @grid = Array.new(x_bounds) { Array.new(y_bounds) {"."}} # instantiate a 2d array w/ " " for empties
  end

  def write(x, y)
    #puts "trying to write #{x},#{y}"
    if (y < @grid.length && y >= 0) then
      if (x < @grid[x].length && x >= 0) then
        @grid[x][y] = 'X'
        return true
      else
        #puts "x bounds error"
        return false
      end
    else
      #puts "weird bounds error detected."
      return false
    end
  end

  def print # guh, this method seems needlessly complicated :/
    print_grid = ""
    0.upto(@grid[0].length - 1) do |y|
      line = ""
      0.upto(@grid.length - 1) do |x|
        line += @grid[x][y]
        line += " " unless x == @grid.length - 1
      end
      print_grid += "#{line}\n"
    end
    print_grid
  end

  def to_s
    print
  end

end

class LogoCursor
  def initialize(grid_bounds_x = 1, grid_bounds_y = 1)
    @grid = LogoGrid.new(grid_bounds_x,grid_bounds_y) # seems like there is a better / more intuitive way to do this
    @x = (grid_bounds_x / 2) # set cursor in the center, assume the benevolence of the puzzle params will pass us odd numbers for the grid bounds
    @y = (grid_bounds_y / 2)
    @grid.write(@x,@y)
    @direction_in_degrees = 0
  end

  def rotate(degrees, counter_clockwise = false)
    if !counter_clockwise # this if statement feels mad clunky, isn't there a more eloquent way to do this?
      @direction_in_degrees += degrees
      if @direction_in_degrees >= 360 then @direction_in_degrees -= 360 end # assuming degrees < 360
      # right here             ^^ is where i made my mistake. is this a bad pattern?
    else
      @direction_in_degrees -= degrees
      if @direction_in_degrees < 0 then @direction_in_degrees += 360 end 
    end
    @direction_in_degrees
  end

  def rotation
    @direction_in_degrees
  end

  def move(reverse = false)
    new_x = @x
    new_y = @y
    actual_direction = reverse ? @direction_in_degrees + 180 : @direction_in_degrees
    if actual_direction >= 360 then actual_direction -= 360 end # i don't like thissss :(
    case actual_direction
    when 0
      new_y -= 1
    when 45
      new_x += 1
      new_y -= 1
    when 90
      new_x += 1
    when 135
      new_x += 1
      new_y += 1
    when 180
      new_y +=1
    when 225
      new_x -= 1
      new_y += 1
    when 270
      new_x -= 1
    when 315
      new_x -= 1
      new_y -= 1
    else
      #puts "WTFFFF!! #{actual_direction}" # TODO
    end
    if @grid.write(new_x, new_y) then
      @x = new_x
      @y = new_y
      return true
    end
    return false
  end

  def move_in_steps(steps, reverse = false)
    0.upto(steps - 1) do
      move reverse
    end
  end

  def move_forward(steps)
    move_in_steps steps
  end

  def move_backward(steps)
    move_in_steps steps, true
  end

  def print_grid
    @grid.print
  end

end

# next step is writing a wrapper (which implements REPEAT plus RT, FD, BD, etc)
class TurtleWrapper
  def initialize(size)
    size = size.to_i # we expect a string but ostensibly you could pass this wrapper a number so...
    @cursor = LogoCursor.new(size,size) #TODO: shit is always square
  end

  def command(command_string)
    # do a case on the first word
    command_to_do, steps, repeat_command = command_string.split " ", 3
    steps = steps.to_i
    case command_to_do
    when "FD" # move forward
      @cursor.move_forward steps
    when "BK" # move backward
      @cursor.move_backward steps
    when "RT" # rotate clockwise
      @cursor.rotate steps
    when "LT" # rotate CC
      @cursor.rotate steps, true
    when "REPEAT"
      steps.times { command repeat_command.gsub('[ ','').gsub(' ]','') } # i know it's wrong but...
    end
    #puts "recurring w/ command #{repeat_command}" unless (repeat_command == nil || command_to_do == "REPEAT" || repeat_command.strip == '')
    command repeat_command unless (repeat_command == nil || command_to_do == "REPEAT" || repeat_command.strip == '')
  end

  def print
    @cursor.print_grid
  end
end

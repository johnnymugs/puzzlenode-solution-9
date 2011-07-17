class TurtleGrid

  def initialize(bounds)
    @grid = Array.new(bounds) { Array.new(bounds) {"."}} # instantiate a 2d array w/ "." for empties
  end

  def write(x, y)
    if (y < @grid.length && y >= 0) then
      if (x < @grid[0].length && x >= 0) then
        @grid[x][y] = 'X'
        return true
      else
        # bounds error
        # given the context (trustworthy input file), this shouldn't really happen, but I want to handle errors @ the cursor level
        return false
      end
    else
      # bounds error
      return false
    end
  end

  def print # this is a pretty ugly chunk of code, seems like there should be a more idiomatic way of doing each line almost... but what? 
    print_grid = ""
    0.upto(@grid[0].length - 1) do |y|
      line = ""
      0.upto(@grid.length - 1) do |x|
        line += @grid[x][y]
        line += " " unless x == @grid.length - 1 # each element is separated by a space, unless we're at the end of the line
      end
      print_grid += "#{line}\n"
    end
    print_grid
  end

  def to_s
    print
  end

end

class TurtleCursor
  def initialize(grid_bounds)
    @grid = TurtleGrid.new(grid_bounds) # this seems a little too tightly coupled, but for such a simple program KISS seems more important
    @x = (grid_bounds / 2) # set cursor in the center, assume the benevolence of the puzzle params will pass us odd numbers for the grid bounds
    @y = @x
    @grid.write(@x,@y)
    @direction_in_degrees = 0 # init facing dead ahead
  end

  def rotate(degrees, counter_clockwise = false)
    if !counter_clockwise # this if statement feels mad clunky, isn't there a more eloquent way to do this?
      @direction_in_degrees += degrees
      if @direction_in_degrees >= 360 then @direction_in_degrees -= 360 end # assuming degrees < 360
      # was missing a "=" here ^^ is where i made my mistake. is this a bad pattern? or I should have used tests
    else
      @direction_in_degrees -= degrees
      if @direction_in_degrees < 0 then @direction_in_degrees += 360 end 
    end
    @direction_in_degrees
  end

  def move(reverse = false)
    new_x = @x
    new_y = @y
    actual_direction = reverse ? @direction_in_degrees + 180 : @direction_in_degrees
    if actual_direction >= 360 then actual_direction -= 360 end # "wrap around" the turn if we go "too far"
    case actual_direction
    # I could this could be less verbose, you could group them by X,Y changes, but I think this is easier to read/troubleshoot
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
      # if this happens we must have a big error in the program since in this context the input is considered to be trustworthy
      raise 'Encountered invalid rotation value: #{actual_direction} Aborting.'
    end
    if @grid.write(new_x, new_y) then
      @x = new_x
      @y = new_y
      return true
    else
      # we could build this to be tolerant of bounds errors, but in the context, if we go out of bounds it means we've made a mistake in processing commands
      raise "An invalid move command was issued."
    end
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

class TurtleWrapper
# a wrapper for the cursor and grid that parses the actual commands from the file/interface
  def initialize(size)
    size = size.to_i # we expect an integer but ostensibly you could pass a string
    @cursor = TurtleCursor.new(size)
  end

  def send_command(command_string) # I know there's some meta-programming magic I could swing here but again, KISS is my priority for this
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
    when "REPEAT" # recur n times
      steps.times { send_command repeat_command.gsub('[ ','').gsub(' ]','') } # I know those gsubs are clunky but they get the job done
    else
      # if this happens, then we've erroneously encountered a parse error, since we consider the input trustworthy in this context
      raise "Encountered an error parsing the command #{command_to_do}." unless command_to_do.strip == "" # but of course ignore empty commands
    end
    # many commands can be strung along in a single command so recur until we're out of commands
    send_command repeat_command unless (repeat_command == nil || command_to_do == "REPEAT" || repeat_command.strip == '')
  end

  def print
    @cursor.print_grid
  end
end

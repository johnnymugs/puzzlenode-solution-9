require './turtle_tools.rb'

file = File.new(ARGV.first) # load the .logo file from the command line
grid_size = file.gets # read grid size from first line, yes this is very trusting but KISS amirite?
turtle = TurtleWrapper.new(grid_size)
while (line = file.gets)
  turtle.command(line)
end
puts turtle.print
file.close

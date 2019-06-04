class SelectionHandler
  attr_accessor :next_selection_handler, :previous_selection_handler

  def handle_input
    input = gets.downcase
    if input.is_a? Integer
      #all methods for selecting search parameters will return integers;
      #it is up to the methods themselves to discern whether or not the
      #input is within range of the size of the lists of parameters
      #to choose from
    else
      #a valid command has not been chosen
      puts "Invalid input."
      display_commands
      handle_input
    end
end

require_relative "../lib/scraper.rb"
require_relative "../lib/command.rb"
require_relative "../lib/change.rb"
require 'nokogiri'
require 'pry'

class CommandLineInterface
  attr_accessor :selected_genres, :selected_formats, :selected_plot_keywords

  def initialize
    #create new Scraper, and store the names of genres and formats (title types)
    #that IMDB uses
    @scraper = Scraper.new
    @genres = @scraper.genres
    @formats = @scraper.formats

    #IMDB uses strings in its search URL's that are different from the strings
    #that the user chooses from; hence, we must store user values as keys in a hash
    #with corresponding search values
    @format_text_and_search_value_hash = @scraper.format_text_and_search_value_hash

    #creating empty arrays for the user's impending choices
    @selected_genres = []
    @selected_formats = []
    @selected_plot_keywords = []
    #this array will store the user's eventual recommendations
    @playlist = []

    #this program keeps track of what commands the user has entered, so that
    #the user can easily go back to their previous selection or to the next
    #recommended selection
    @current_command = nil
    @previous_method = "main_menu"
    @current_method = "main_menu"
    @next_method = "get_genre_selection"

    @commands = [
      Command.new("!e", "Exit program", "terminate"),
      Command.new("!n", "Complete selection/Go to next selection", "execute_next_method"),
      Command.new("!b", "Go to previous selection","execute_previous_method"),
      Command.new("!g", "Select genres", "get_genre_selection"),
      Command.new("!f", "Select formats", "get_format_selection"),
      Command.new("!p", "Select plot keywords", "get_plot_keyword_selection"),
      Command.new("!o", "Get an overview of your current selection", "give_overview"),
      Command.new("!s", "Get matching titles", "get_matches"),
      Command.new("!x", "Delete particular selection", "delete_particular_selection"),
      #Command.new("!u", "Undue most recent change", nil, true),
      #Command.new("!d", "Display commands", "display_commands", true),
      Command.new("!m", "Start over at main_menu", "main_menu"),
      Command.new("!a", "View all matches ever collected", "view_all_matches_ever")
    ]

    #storing command inputs as the keys to a hash whose values are their corresponding
    #methods
    @command_map = {}
    @commands.each {|command| @command_map[command.entry] = command.function_name}

    #while collecting user input in any particular selection, will only move on
    #from the selection if one of these methods is indicated:
    @ordered_methods = ["main_menu", "get_genre_selection", "get_plot_keyword_selection", "get_format_selection", "get_matches"]
    #@ordered_inputs = @ordered_methods.each {|method| @ordered_inputs << @command_map.key(method)}
  end

  def run
    #introduce the user to the program:
    main_menu
    #continue to handle commands until the user gives the command to exit the program
    until @current_command == "!e"
      handle_current_command
    end
  end

  def handle_current_command
    #get command from user if haven't already
    if @current_command == nil
      @current_command = gets.chomp.downcase
    end

    if Command.all_entries.include?(@current_command)
      #if the input given is a valid command, execute the method associated with it
      chosen_method = nil

      #in order to convey the user sequentially through ordered methods,
      #must specify the method associated for the "previous" or "next" method
      #if commanded by the user
      if @current_command == "!b" #the command for the "previous" method
        chosen_method = @previous_method
      elsif @current_command == "!n" #the command for the "next" method
        chosen_method = @next_method
      else
        chosen_method = @command_map[@current_command]
      end

      #store the name_of_previous_method parameter as the new @previous_method
      @previous_method = @current_method
      @current_method = chosen_method

      #determine the next method
      determine_next_method

      #reset current command
      @current_command = nil

      #execute new current method
      self.send(@current_method)
    else
      #reset current command
      @current_command = nil

      #inform user that a valid command has not been entered
      puts "Please enter a valid command."
    end


  end

  def determine_next_method
    #only update which method is next if this method
    #affects the user's selection of parameters for search of entertainment media;
    #such methods are listed in @ordered_methods
    if @ordered_methods.include?(@current_method)
      #find which method is next on the @ordered_methods list, and store that
      #as the @next_method
      index_of_current_method = @ordered_methods.index(@current_method)
      index_of_next_method =  index_of_current_method + 1
      if index_of_next_method >= @ordered_methods.size
        #if the new @current_method is last in the @ordered_methods list, make the
        #@next_method the first method in the list
        index_of_next_method = 0
      end

      @next_method = @ordered_methods[index_of_next_method]
    end
  end

  def main_menu
    #this method introduces the user to the functionality of the program
    #and also serves as a 'reset' for the user's chosen values
    @selected_genres = []
    @selected_formats = []
    @selected_plot_keywords = []
    @playlist = []

    #keep track of recent Changes (undo and redo operations) that add or remove
    #items from this selection
    @undo_operations = []
    @redo_operations = []

    puts "Welcome to the CLI Entertainment Recommendation Service!"
    puts
    puts "This program will prompt you to specify genres, formats and plot details of entertainment media that"
    puts "you are interested in consuming, and then scrape through the Internet Move Database"
    puts "to give you recommendations (a total of 5 for now, since the scraping is time-consuming)."
    puts

    puts "Here are some commands you can invoke at any time: "
    display_commands
    puts
    puts "To proceed, enter !n, or any other command."
    puts
  end

  def display_commands
    @commands.each{|command| puts "#{command.entry}: #{command.description}"}
  end

  #the next three functions affect acquisition of parameters from user for search,
  #and hence are given an arbitrary order in the @ordered_methods list
  def get_genre_selection
    get_selection("genres", @selected_genres, @genres)
  end

  def get_format_selection
    get_selection("formats", @selected_formats, @formats)
  end

  def get_plot_keyword_selection
    puts
    puts "Enter some keywords that describe the plot you are interested in."
    get_selection("plot keywords", @selected_plot_keywords, @plot_keywords)
  end

  def get_selection(selection_type, selection, choices = nil)
    #display the user's current selection of search-parameters for this category
    puts "Here is your current selection for #{selection_type}:"
    display_fields(selection)

    #if this category has a limited number of options to choose from, display those
    #choices
    if choices != nil
      puts "Here are some #{selection_type} to choose from: "
      display_fields(choices)
    end

    puts
    puts "Please enter as many search parameters as you wish."
    puts "You may enter the number associated with a choice if you prefer." if choices != nil
    puts "To undo your most recent change, enter !u."
    puts "To redo your most recent change, enter !r."
    puts "When finished, enter \"!n\" or a different command."
    puts

    #collect input from user
    input = gets.chomp.downcase

    #until the user gives a command that progresses the program,
    #continue collecting new search parameters
    until Command.all_entries.include?(input)
      #at any time, the user may enter "!d" to display commands
      if input == "!d"
        display_commands
      elsif input == "!u"
        #the user has chosen to undo their most recent change:
        effect_change(true)
      elsif input == "!r"
        #the user has chosen to redo their most recent change:
        effect_change(false)
      elsif choices != nil
        #if choices were supplied:
        adjusted_input = input.to_i - 1
        if adjusted_input.between?(0, choices.size - 1)
          #if the user gave an input that happens to be a number associated with
          #a valid choice, add the associated choice to the selection:
          associated_string = choices[(input.to_i - 1)]
          selection << associated_string
          #create a new undo operation:
          @undo_operations << Change.new(associated_string, true, selection_type)
        elsif !choices.include?(input)
         #if the input given is not among the choices
         #available, give error message:
         puts "Please choose from one of the #{selection_type} available."
        else
          #the input given is a valid string (as opposed to a number associated with a choice);
          #add it to the selection:
          selection << input
          @undo_operations << Change.new(input, true, selection_type)
        end
      elsif input != nil
        #if the input supplied is not nil, and is not required to be from a list
        #of prescribed options (as determined in the preceding elsif),
        #add this input as a search parameter for this category
        selection << input
        @undo_operations << Change.new(input, true, selection_type)
      else
        #input given is not a command, and is nil
        puts "Please enter a valid input."
      end

      input = gets.chomp.downcase
    end

    #a command has been given, ending the until loop; store the command in @current_command
    #so its associated method can be executed in the next iteration of the until loop
    #in the "run" method
    @current_command = input
  end

  def give_overview
    #this method reminds the user of their chosen search values so far:
    puts "Here are your preferred genres: "
    display_fields(@selected_genres)
    puts

    puts "Here are your preferred plot keywords: "
    display_fields(@selected_plot_keywords)
    puts

    puts "Here are your preferred formats: "
    display_fields(@selected_formats)
    puts

    #get_matches
  end

  def view_all_matches_ever
    all_matches = EntertainmentProduct.all

    if all_matches.empty?
      puts "No matches yet collected."
    else
      all_matches.each do |match|
        match.instance_variable_hash.each do |key, value|
          puts "#{key.to_s.tr("_", " ")}: #{value}"
        end
        puts
      end      
    end
  end

  def effect_change(is_undo)
    #determine the operations being employed, and the opposite_operations
    #that will add this operation so it will later be undoable or redoable
    operations = is_undo ? @undo_operations : @redo_operations
    opposite_operations = !is_undo ? @undo_operations : @redo_operations
    #store information relevant to operation being invoked for easy access:
    most_recent_change = operations.last
    item_affected = most_recent_change.item
    is_addition = most_recent_change.is_addition
    selection_name = most_recent_change.selection_name
    method_name = "selected_"
    method_name << selection_name.tr(" ", "_")
    selection = self.send(method_name)

    if (is_addition && !is_undo) || (!is_addition && is_undo)
      #if redoing an addition, or undoing a deletion, add the item_affected to the selection
      selection << item_affected
      puts "added #{item_affected} to #{selection_name}."
    else
      #if redoing a deletion, or undoing an addition, remove the item_affected from the selection
      selection.delete(item_affected)
      puts "removed #{item_affected} from #{selection_name}."
    end

    #add new opposite operation to the one just invoked:
    new_change = Change.new(item_affected, is_addition, selection_name)
    opposite_operations << new_change

    #remove this operation from the list of remaining invokable operations of this type (undo or redo)
    operations.pop
  end

  def effect_change_verbosely(redo_operations, undo_operations, is_undo, selection)
    #at present this method isn't used; it is a template for the simplified
    #effect_change method; since that method is very abstract, it may be easier
    #to understand what it does by examining this method
    operations = is_undo ? undo_operations : redo_operations
    most_recent_change = operations.last
    item_affected = most_recent_change.item
    is_addition = most_recent_change.is_addition

    if is_addition
      if is_undo
        #if the user is undoing an addition, delete the addition from the selection:
        selection.delete(item_affected)
        #add a new redo operation, indicating an addition
        @redo_operations << Change.new(item_undone, is_addition)
        #notify the user of the change:
        puts "#{item_affected} removed from search parameters."
      else
        #if the user is redoing an addition, add the item to the selection
        selection << item_affected
        #add a new undo operation, indicating an addition
        undo_operations << Change.new(item_undone, is_addition)
        #notify the user of the change:
        puts "#{item_affected} added back to search parameters."
      end
    else
      if is_undo
        #if the user is undoing a deletion, add the deleted item back to the selection:
        selection << item_undone
        #add a new redo operation to the redo hash and array, indicating a deletion
        @redo_operations << Change.new(item_undone, !is_addition)
        #notify the user of the change:
        puts "#{item_undone} restored to search parameters."
      else
        #if the user is redoing a deletion, delete the item from the selection:
        selection.delete(item_affected)
        #add a new undo operation to the undo hash and array, indicating a deletion
        undo_operations << Change.new(item_redone, !is_addition)
        #notify the user of the change:
        puts "#{item_affected} removed from search parameters."
      end
    end

    #remove this undo operation from the undo hash and array
    undo_operations.pop
  end

  def delete_choices_from_selection(relevant_selection)
    #show what search parameters the user has chosen for this category
    puts "Here is your current selection:"
    display_fields(relevant_selection)
    puts

    #if the user has not chosen any search parameters for this category, indicate this
    if relevant_selection.size == 0
      puts "There are no choices to delete."
    else
      puts "\nPlease select the numbers corresponding to the search parameters you would like to delete.\n"
      puts "\nTo undo the most recent deletion, enter \"!u\"."
      puts "When finished, enter \"!n\" or a different command.\n"
      input = gets.chomp.downcase
      #this variable will store the most recently deleted search parameter,
      #in case the user wishes to reverse this decision immediately after
      most_recent_deletion = nil

      #until the user gives a command to continue, or a different command
      until Command.all_entries.include?(input)
        if input == "!d"
          display_commands
        elsif input == "!u"
          #the user has chosen to undo their most recent deletion
          if most_recent_deletion == nil
            puts "No deletions to undue."
          else
            puts "#{most_recent_deletion} restored to search parameters."
            relevant_selection << most_recent_deletion
          end
        else
          #converting user input from string into integer array index
          index_to_delete = input.to_i - 1
          if index_to_delete.between?(0, relevant_selection.size - 1)
            #if the input is within the range of the array size, delete entries
            #in its corresponding selection
            most_recent_deletion = relevant_selection[index_to_delete]
            relevant_selection.delete_at(index_to_delete)
            puts "#{most_recent_deletion} deleted from search parameters."
          else
            #inform the user that they did not choose a valid number
            puts "Please enter a number from 1 to #{relevant_selection.size + 1}."
          end
        end

        input = gets.chomp.downcase
      end

      @current_command = input
    end
  end

  def delete_particular_selection
    puts
    puts "Enter the number of the category whose selection you wish to revise: "
    puts "1. Genres"
    puts "2. Formats"
    puts "3. Plot Keywords"

    input = gets.chomp.downcase
    relevant_selection = nil
    selection_name = nil

    #indefinitely soliciting a valid number or command:
    until input.to_i.between?(1, 3) || Command.all_entries.include?(input)
      if Command.all_entries.include?(input)
        #if a valid command is given, prepare for the next iteration of the
        #until loop in the "run" method:
        @current_command = input
        return
      else
        puts "Please select 1, 2 or 3, or input a different command.\n"
        input = gets.chomp.downcase
      end
    end

    #determing the user's intended selection, and giving that selection a printable
    #selection_name
    case input
    when "1"
      relevant_selection = @selected_genres
      selection_name = "genres"
    when "2"
      relevant_selection = @selected_formats
      selection_name = "formats"
    when "3"
      relevant_selection = @selected_plot_keywords
      selection_name = "plot keywords"
    end

    #deletion will be handled here:
    delete_choices_from_selection(relevant_selection)
  end

  def terminate
    exit
  end

  def get_matches
    #generating a search url from user's search paramters, and then scraping the
    #recommendations from the search page
    if self.sufficient_params?
      url = @scraper.generate_search_url(@selected_formats, @selected_genres, @selected_plot_keywords)
      puts url
      @playlist = @scraper.scrape_user_search_url(url)
      if @playlist.empty?
        puts "Sorry, but there are no matching entertainment media in the database."
      else
        puts "Here are your matches: "
        @playlist.each do |match|
          match.instance_variable_hash.each do |key, value|
            puts "#{key.to_s.tr("_", " ")}: #{value}"
          end
          puts
        end
      end
    else
      puts "Must have at least one parameter before launching a search."
    end
  end

  def sufficient_params?
    !(@selected_genres.empty? && @selected_formats.empty? && @selected_plot_keywords.empty?)
  end

  #not currently implemented
  def execute_next_method
    self.send(@next_method)
  end

  #not currently implemented
  def execute_previous_method
    self.send(@previous_method)
  end

  #displaying fields available to choose from, and storing them in a hash
  #whereby they are values mapped to numbers as keys
  def display_fields(fields)
    size = fields.size
    for i in 0..size - 1
      print "#{i+1}. #{fields[i]}"
      #print "#{fields[i]}"
      print ", " if i < size - 1
    end
    puts
  end
end

require_relative "../lib/scraper.rb"
require_relative "../lib/Command.rb"
require 'nokogiri'

class CommandLineInterface

  def initialize
    @scraper = Scraper.new
    @genres = @scraper.scrape_genres
    @formats = @scraper.scrape_title_types
    @selected_genres = []
    @selected_formats = []
    @selected_plot_keywords = []
    @playlist = []

    @previous_method = nil
    @current_method = "main_menu"
    @next_method = "get_genre_selection"

    @commands = [
      Command.new("!e", "Exit program", "terminate"),
      Command.new("!n", "Complete selection/Go to next selection", "execute_next_method"),
      Command.new("!g", "Select genres", "get_genre_selection"),
      Command.new("!f", "Select formats", "get_format_selection"),
      Command.new("!p", "Select plot keywords", "get_plot_keyword_selection"),
      Command.new("!x", "Delete particular selection", "delete_particular_selection"),
      #Command.new("!u", "Undue most recent change", ""),
      Command.new("!d", "Display commands", "display_commands"),
      Command.new("!b", "Go to previous selection","execute_previous_method"),
      Command.new("!m", "Start over at main_menu", "main_menu"),
      Command.new("!s", "Get matching titles", "get_matches")
    ]

    @ordered_methods = ["main_menu", "get_genre_selection", "get_format_selection", "get_plot_keywords", "get_matches"]
    #@progressive_commands = ["!m", "!g", "!f", "!p", "!s"]
    #@transient_commands = @commands.select {|cmd| !@ordered_commands.include?(cmd.entry)}
    @progressive_commands = []
    @transient_commands = []

    @command_map = {}
    @commands.each {|command| @command_map[command.entry] = command.function_name}
  end

  def run

    main_menu

    #handle_input(false) {puts "Please enter a valid command."}

  end

  def main_menu
    @selected_genres = []
    @selected_formats = []
    @selected_plot_keywords = []
    @playlist = []
    puts "Welcome to the CLI Entertainment Recommendation Service!"
    puts
    puts "This program will prompt you to specify genres and plot details of entertainment media that"
    puts "you are interested in consuming, and then scrape through the Internet Move Database"
    puts "to give you recommendations."
    puts
    #puts "You may press the Escape key at any time to exit the program, or the \'m\' key to return to the main menu."
    #puts "Pressing \'b\' will take you back to the previous part of the program."
    #puts "Press Tab to continue."
    #display_selection
    display_commands
    #get_genre_selection

    handle_input(false)
  end

  def display_commands
    @commands.each{|command| puts "#{command.entry}: #{command.description}"}
  end

  def handle_input(expecting_return?, provided_input = nil)
    #if no input is provided, get input from user, remove whitespace,
    #and put it in lowercase
    input = gets.chomp.downcase if provided_input == nil

    #if the input given is a valid command, update which methods are
    #current, previous and next, and execute the function associated
    #with the command
    if Command.all_names.include?(input)
      chosen_method = @command_map[input]
      #only update which methods are previous, current and next if this method
      #affects the user's selection of parameters for search of entertainment media;
      #such methods are listed in @ordered_methods
      if @ordered_methods.include?(chosen_method)
        #for now, we are treating the function stored as the @current_method
        #as the previous method, and the @chosen_method as the new "current" method
        update_method_order(@current_method, chosen_method)
      end
      #execute the function mapped to the valid command input
      self.send(chosen_method)
    elsif expecting_return?
      #if the user has not input a command, and this function has been called
      #in one of the ordered methods (which affects user input) as expecting a return,
      #the user is providing a parameter in the eventual search, and must be returned
      return input
      #it is up to the individual methods for parameter selection
      #to verify that this is valid input
    else
      #the method calling this function is not expecting a return, and a valid
      #command has not been entered
      puts "Please input a valid command."
    end
  end

  def update_method_order(name_of_previous_method, name_of_current_method)
    #store the name_of_previous_method parameter as the new @previous_method
    @previous_method = name_of_previous_method
    #store the name_of_current_method parameter as the new @current_method
    @current_method = name_of_current_method
    #find which method is next on the @ordered_methods list, and store that
    #as the @next_method
    index_of_current_method = @ordered_methods.index(@current_method)
    index_of_next_method =  index_of_current_method + 1
    if index_of_next_method == @ordered_methods.size
      #if the new @current_method is last in the @ordered_methods list, make the
      #@next_method the first method in the list
      index_of_next_method = 0
    end

    @next_method = @ordered_methods[index_of_next_method]
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
    puts "Type in some keywords that describe the plot you are interested in."
    get_selection("plot keywords", @selected_plot_keywords, @plot_keywords)
  end

  def get_selection(selection_type, selection, choices = nil)
    #display the user's current selection of search-parameters for this category
    #(the user has the flexibility to return to this function at any time before
    #finalizing his or her choices for search-paramters)

    puts "Here is your current selection for #{selection_type}:"
    display_fields(selection)

    #if this category has a limited number of options to choose from, display those
    #choices
    if choices != nil
      puts "Here are some #{selection_type} to choose from: "
      display_fields(choices)
    end

    puts "Please enter as many search parameters as you wish."
    puts "To undo your most recent addition, enter \"!u\"."
    puts "To delete any previous choices for search paramters, enter \"!x\"."
    puts "When finished, enter \"!n\" or a different command.\n"

    #collect input from user
    input = gets.chomp.downcase
    #will store newest search parameter given by user here, so that it can be removed
    #at will using the "!u" command
    most_recent_addition = nil

    #until the user gives a command that is not the "display commands" command,
    #continue collecting new search parameters
    until Command.all_names.include?(input) && input != "!d"
      #if the user gives the command to undo the most recent search parameter,
      #first check that at least one such parameter has already been given,
      #then remove the most recent searh parameter added
      if input == "!u"
        #if no search parameters have been given, inform the user
        if most_recent_addition == nil
          puts "No additions to undue."
        else
          #search parameters have been given; delete the most recently added search
          #parameter, stored in most_recent_addition
          puts "#{most_recent_addition} removed from search parameters."
          relevant_selection.delete(most_recent_addition)
        end
      elsif input == "!x"
        #the user has chosen to delete the most recent search term added, which
        #will be handled by passing the relevant selection to the following method:
        delete_choices_from_selection(selection)
      #below this point, the user has given an input that is not a command, and
      #hence wishes to include it as a search parameter
      elsif choices != nil && !choices.include?(choice)
        #if choices were supplied, and the input given is not among the choices
        #available, give error message:
        puts "Please choose from one of the #{selection_type} available."
      elsif input != nil
        #if the input supplied is not nil, and is not required to be from a list
        #of prescribed options (as determined in the preceding elsif),
        #add this input as a search parameter for this category
        selection << input
        #store this search parameter as the most_recent_addition to the selection
        most_recent_addition = input
      else
        #input given is not a command, and is nil
        puts "Please enter a valid input."
        end
      end

      input = gets.chomp.downcase
    end

    #a command has been given, ending the until loop; now we must pass
    #this command to the handle_input function
    handle_input(false, input)
  end

  def delete_choices_from_selection(relevant_selection)
    #show what search parameters the user has chosen for this category
    display_fields(relevant_selection)

    #if the user has not chosen any search parameters for this category, indicate this
    if relevant_selection.size == 0
      puts "There are no choices to delete."
    else
      puts "Please select the numbers corresponding to the search parameters you would like to delete."
      pust "To undo the most recent deletion, enter \"!u\"."
      puts "When finished, enter \"!n\" or a different command."
      input = gets.chomp.downcase
      #this variable will store the most recently deleted search parameter,
      #in case the user wishes to reverse this decision immediately after
      most_recent_deletion = nil

      #until the user gives a command to continue, or a different command
      until Command.all_names.include?(input) && input != "!d"
        if input == "!u"
          if most_recent_deletion == nil
            puts "No deletions to undue."
          else
            puts "#{most_recent_deletion} restored to search parameters."
            relevant_selection << most_recent_deletion
          end
        else
          index_to_delete = handle_input(true).to_i - 1
          if (0..relevant_selection.size).include? index_to_delete
            most_recent_deletion = relevant_selection[index_to_delete]
            relevant_selection.delete_at(index_to_delete)
          else
            puts "Please enter a number from 1 to #{relevant_selection.size + 1}."
          end
        end

        input = gets.chomp.downcase
      end

      handle_input(false, input)
  end

  def delete_particular_selection
    puts "Enter the number of the category whose selection you wish to revise: "
    puts "1. Genres"
    puts "2. Formats"
    puts "3. Plot Keywords"

    input = handle_input(true)
    relevant_selection = nil

    case input
    when "1"
      relevant_selection = @selected_genres
    when "2"
      relevant_selection = @selected_formats
    when "3"
      relevant_selection = @selected_plot_keywords
    else
      puts "Please select 1, 2 or 3, or input a different command.\n"
      delete_particular_selection
    end

    delete_choices_from_selection(relevant_selection)
  end

  def terminate
    exit
  end

  def get_matches
    if self.sufficient_params?
      url = @scraper.generate_search_url(@selected_formats, @selected_genres, @selected_plot_keywords)
      @playlist = @scraper.scrape_user_search_url(url)
      puts "Here are your matches: "
      for match in @playlist
        match.each do |key, value|
          puts "#{key}: #{value}"
        end
        puts ""
      end
    else
      puts "Must have at least one parameter before launching a search."
    end
  end

  def sufficient_params?
    !(@selected_genres.empty? && @selected_formats.empty? && @selected_plot_keywords.empty?)
  end

  #at present, this method will never be called, but it may be useful in future
  #versions of this program
  def execute_next_method
    self.send(@next_method)
  end

  #at present, this method will never be called, but it may be useful in future
  #versions of this program
  def execute_previous_method
    self.send(@previous_method)
  end

  #displaying fields available to choose from, and storing them in a hash
  #whereby they are values mapped to numbers as keys
  def display_fields(fields)
    size = fields.size
    for i in 0..size
      print "#{fields[i + 1]}"
      print ", " if i < size - 1
    end
    puts
  end
end

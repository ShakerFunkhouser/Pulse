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
    @ordered_methods = ["main_menu", "get_genre_selection", "get_format_selection", "get_plot_keywords"]
    @previous_method = nil
    @current_method = "main_menu"
    @next_method = "get_genre_selection"

    @commands = [
      Command.new("-e", "Exit program", "terminate"),
      Command.new("-n", "Complete selection/Go to next selection", "execute_next_method"),
      Command.new("-g", "Select genres", "get_genre_selection"),
      Command.new("-f", "Select formats", "get_format_selection"),
      Command.new("-p", "Select plot keywords", "get_plot_keyword_selection"),
      Command.new("-d", "Display commands", "display_commands"),
      Command.new("-b", "Go to previous selection","execute_previous_method"),
      Command.new("-m", "Start over at main_menu", "main_menu"),
      Command.new("-s", "Get matching titles", "get_matches")
    ]
    @command_map = {}
    @commands.each {|command| @command_map[command.name] = command.function_name}
  end

  def run

    main_menu

    #handle_input(false) {puts "Please enter a valid command."}

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
      puts "Must have at least parameter before launching a search."
    end
  end

  def sufficient_params?
    !(@selected_genres.empty? && @selected_formats.empty? && @selected_plot_keywords.empty?)
  end

  def get_selection(selection_type, selection, choices = nil)
    puts "Here is your current selection for #{selection_type}:"
    display_fields(selection)
    if choices != nil
      puts "Here are some #{selection_type} to choose from: "
      display_fields(choices)
    end

    #puts "Type in as many choices as you like. When finished enter /'-n/', or enter another available command."
    choice = handle_input(true) #if  user enters command indicating selection of
    #different method, the remainder of this method will not be executed;
    #otherwise, the input given pertains to this selection type

    if choices != nil && !choices.include?(choice)
      #if choices were supplied, and the choice is not among the choices
      #available, give error message:
      puts "Please choose from one of the #{selection_type} available."
    elsif choice != nil
      selection.push(choice)
      #only add this choice to selection if it is not nil, as would be expected
      #if invoking another command
    end
    get_selection(selection_type, selection, choices) if choice != nil

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
    @commands.each{|command| puts "#{command.name}: #{command.description}"}
  end

  def handle_input(expecting_return, provided_input = nil)
    input = gets.chomp.downcase if provided_input == nil
    if Command.all_names.include?(input)
      chosen_method = @command_map[input]
      if @ordered_methods.include?(chosen_method)
        update_method_order(@current_method, chosen_method)
      end
      self.send(chosen_method)
    elsif expecting_return
      return input
      #it is up to the individual methods for parameter selection
      #to verify that this is valid input
    else
      puts "Please input a valid command."
    end
  end

  def update_method_order(name_of_previous_method, name_of_current_method)
    @previous_method = name_of_previous_method
    @current_method = name_of_current_method
    index_of_current_method = @ordered_methods.index(@current_method)
    index_of_next_method =  index_of_current_method + 1
    if index_of_next_method == @ordered_methods.size
      index_of_next_method = 0
    end

    @next_method = @ordered_methods[index_of_next_method]
  end

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



  #displaying fields available to choose from, and storing them in a hash
  #whereby they are values mapped to numbers as keys
  def display_fields(fields)
    size = fields.size
    for i in 0..size
      print "#{fields[i]}"
      print ", " if i < size - 1
    end
    puts
  end



end

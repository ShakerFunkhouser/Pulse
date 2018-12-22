require_relative "../lib/scraper.rb"
require_relative "../lib/student.rb"
require 'nokogiri'
require 'colorize'

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
    @previous_method = "main_menu"
    @current_method = "main_menu"
    @next_method = "get_genre_selection"

    @commands = [
      Command.new("!e", "Exit program", "terminate")
      Command.new("!n", "Complete selection/Go to next selection", "execute_next_method")
      Command.new("!g", "Select genres", "get_genre_selection")
      Command.new("!f", "Select formats", "get_format_selection")
      Command.new("!p", "Select plot keywords", "get_plot_keyword_selection")
      Command.new("!d", "Display commands", "display_commands")
      Command.new("!b", "Go to previous selection","execute_previous_method")
      Command.new("!m", "Start over at main_menu", "main_menu")
    ]
    @command_map = {}
    @commands.each {|command| @command_map[command.keystroke] = command.function_name}
  end

  def run

    main_menu

    #handle_input

  end

  def terminate
    exit
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
    update_method_order unless
    @selected_genres = []
    @selected_formats = []
    @selected_plot_keywords = []
    @playlist = []
    puts "Welcome to the CLI Entertainment Recommendation Service!"
    puts "This program will prompt you to specify genres of entertainment media that"
    puts "you are interested in consuming, and then scrape through the Internet Move Database"
    puts "to give you recommendations\n."
    #puts "You may press the Escape key at any time to exit the program, or the \'m\' key to return to the main menu."
    #puts "Pressing \'b\' will take you back to the previous part of the program."
    #puts "Press Tab to continue."
    #display_selection
    display_commands
    get_genre_selection

    handle_input
  end

  def handle_command
    input = gets.chomp.downcase
    if Command.all_key_strokes.include?(input)
      self.send(@command_map[input])
    else
      return input
      #it is up to the individual methods for parameter selection
      #to verify that this is valid input
    end
  end

  def update_method_order(name_of_current_method)
    index_of_current_method = @ordered_methods.index(@current_method)
    index_of_next_method =  index_of_current_method + 1
    if index_of_next_method == @ordered_methods.size
      index_of_next_method = 0
    end

    @next_method = @ordered_methods[index_of_next_method]
    @previous_method = @current_method
    @current_method = name_of_current_method
  end

  def display_selection(fields)
    genre_count = 1
    puts "Genres selected: "
    display_fields(@selected_genres)
    puts ""

    puts "Formats selected: "
    display_fields(@selected_formats)
    puts ""
  end

  def display_commands
    @commands.each{|command| puts "#{command.name}: #{command.description}"}
  end

  def get_genre_selection
    get_selection("genre", @genres)
  end

  def get_format_selection
    get_selection("format", @formats)
  end

  def get_plot_keyword_selection
    puts "Type in some keywords that describe the plot you are interested in."
    input = gets.downcase
    while !command_map.keys.include?(input)

    end
    handle_command
  end

  def get_selection(field_name, fields)
    puts "Here is a list of #{field_name} to choose from: "
    fields_map = display_fields(fields)
    display_selection
    proceed = false

    while !proceed
      #if user presses tab, will
      input = handle_input {get_selection(false, @formats)}
      break if input.is_a? String

      field_num = input.to_i
      if field_num.between?(1, fields.size)
        selection << fields_map[field_num]
      else
        puts "Please select a valid number."
      end
    end
  end

  #displaying fields available to choose from, and storing them in a hash
  #whereby they are values mapped to numbers as keys
  def display_fields(fields)
    count = 1
    fields_map = {}
    fields.each do |field|
      print "#{count}. #{field} "
      genre_map[count] = genre
    end
    fields_map
  end

  def make_students
    students_array = Scraper.scrape_index_page(BASE_PATH + 'index.html')
    Student.create_from_collection(students_array)
  end

  def add_attributes_to_students
    Student.all.each do |student|
      attributes = Scraper.scrape_profile_page(BASE_PATH + student.profile_url)
      student.add_student_attributes(attributes)
    end
  end

  def display_students
    Student.all.each do |student|
      puts "#{student.name.upcase}".colorize(:blue)
      puts "  location:".colorize(:light_blue) + " #{student.location}"
      puts "  profile quote:".colorize(:light_blue) + " #{student.profile_quote}"
      puts "  bio:".colorize(:light_blue) + " #{student.bio}"
      puts "  twitter:".colorize(:light_blue) + " #{student.twitter}"
      puts "  linkedin:".colorize(:light_blue) + " #{student.linkedin}"
      puts "  github:".colorize(:light_blue) + " #{student.github}"
      puts "  blog:".colorize(:light_blue) + " #{student.blog}"
      puts "----------------------".colorize(:green)
    end
  end

end

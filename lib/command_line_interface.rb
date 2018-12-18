require_relative "../lib/scraper.rb"
require_relative "../lib/student.rb"
require 'nokogiri'
require 'colorize'

class CommandLineInterface

  def run
    scraper = Scraper.new
    genres = scraper.scrape_genres
    formats = scraper.scrape_title_types

    puts "Welcome to the CLI Entertainment Recommendation Service!"
    puts "This program will prompt you to specify genres of entertainment media that"
    puts "you are interested in consuming, and then scrape through the Internet Move Database"
    puts "to give you recommendations\n."
    puts "Here is a list of genres to choose from: "

    genre_map = display_fields(genres, genre_map)

    puts "Enter the numbers of the genres you are interested in. When finished, press Escape."
    selected_genres = []
    proceed = false

    while !proceed
      input = gets
      if input == "\e" || input == "\x1b"
        proceed = true
        break
      end

      genre_num = input.to_i
      if genre_num.between?(1, genres.size)
        selected_genres << genre_map[genre_num]
      else
        puts "Please select a valid number."
      end
    end

    puts "Here is a list of formats for you to choose from: "
    #puts "To go back, press Escape."
    format_map = display_fields(formats, format_map)
    selected_formats = []
    proceed = false

    while !proceed
      input = gets
      if input == "\e" || input == "\x1b"
        run
        proceed = true
        break
      end

      format_num = input.to_i
      if format_num.between?(1, formats.size)
        selected_formats << format_map[format_num]
      else
        puts "Please select a valid number."
      end
    end


  end

  def process_fields
    
  end
  def display_fields(fields, fields_map)
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

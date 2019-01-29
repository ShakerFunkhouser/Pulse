def update_method_order_2(name_of_previous_method, name_of_current_method)
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


def get_selection_2(field_name, fields) #another version of get_selection, but choosing from numbers
  puts "Here is a list of #{field_name} to choose from: "
  fields_map = display_fields(fields)
  display_selection
  input = gets.chomp.downcase

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

def handle_input(expecting_return, provided_input = nil)
  input = gets.chomp.downcase if provided_input == nil
  if Command.all_key_strokes.include?(input)
    chosen_method = @command_map[input]
    update_method_order(@current_method, chosen_method)
    self.send(chosen_method)
  elsif expecting_return
    return input
    #it is up to the individual methods for parameter selection
    #to verify that this is valid input
  else
    yield
  end
end

def display_fields(fields)
  count = 1
  fields_map = {}
  fields.each do |field|
    print "#{count}. #{field} "
    fields_map[count] = field
    count += 1
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

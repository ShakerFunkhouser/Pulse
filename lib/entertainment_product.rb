class EntertainmentProduct
  #attr_accessor :genres, :plot_keywords, :imdb_rating, :title_type, :release_date, :title, :rating
  # add an option to your CLI class that allows a user to view all the EntertainmentProducts that have matched their previous searches in a session

  # 1. start by adding aclass variable called `@@all` here in EP
  # 2. when an EP gets initialized, it should save to @@all unless it already exists there
  # 3. add a class find_or_create method or at least a find method that takes the hash of attributes and returns whetner the EP already extsis
  attr_accessor :instance_variable_hash
  @@all = []

  def initialize(args)
    @instance_variable_hash = args
    args.each {|k, v| instance_variable_set("@#{k}", v) unless v.nil?}

    @@all << self unless already_exists(args)
  end

  def self.all
    @@all
  end

  def already_exists(args)
    
    if @@all.empty?
      return false
    else
      @@all.each do |existing_entry|
        return true if existing_entry.instance_variable_hash[:title] == args[:title]
        #args.each do |k, v|

        #  if existing_entry.instance_variable_hash[k] != v
        #    return false
        #  end
        #end
      end
    end

    false
  end
end

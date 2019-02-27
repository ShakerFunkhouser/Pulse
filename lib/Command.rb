class Command
  attr_reader :entry, :description, :function_name
  @@all = []
  @@all_entries = []

  def initialize(entry, description, function_name)
    @entry = entry
    @description = description
    @function_name = function_name
    @@all << self
    @@all_entries << entry
  end

  def self.all_entries
    @@all_entries
  end
end

class Command
  attr_reader :entry, :description, :function_name, :progresses?
  @@all = []
  @@all_entries = []

  def initialize(entry, description, function_name, progresses?)
    @entry = entry
    @description = description
    @function_name = function_name
    @progresses? = progresses?
    @@all << self
    @@all_entry << entry
  end

  def self.all_entries
    @@all_entries
  end
end

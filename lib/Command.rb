class Command
  attr_reader :name, :description, :function_name
  @@all = []
  @@all_names = []

  def initialize(name, description, function_name)
    @name = name
    @description = description
    @function_name = function_name
    @@all << self
    @@all_names << name
  end
end

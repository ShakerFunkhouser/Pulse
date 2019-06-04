class Change
  #I chose to make a class to keep track of changes rather than a hash, since
  #it is conceivable for multiple changes to involve the same item, and a hash
  #cannot accommodate multiple entries with the same key (in this case, the item,
  #or the user input that has been added or removed);
  #this approach also makes for much cleaner code than maintaining insertion order
  #in a hash of changes anyway
  attr_accessor :item, :is_addition, :selection_name

  def initialize(item, is_addition, selection_name)
    @item = item
    @is_addition = is_addition
    @selection_name = selection_name
  end
end

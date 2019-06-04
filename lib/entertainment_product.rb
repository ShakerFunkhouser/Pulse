class EntertainmentProduct
  #attr_accessor :genres, :plot_keywords, :imdb_rating, :title_type, :release_date, :title, :rating
  attr_accessor :instance_variable_hash
  def initialize(args)
    @instance_variable_hash = args
    args.each {|k, v| instance_variable_set("@#{k}", v) unless v.nil?}
  end
end

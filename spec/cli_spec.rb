require 'rspec/autorun'
require_relative "../lib/command_line_interface.rb"


describe "CommandLineInterface" do
  let(:cli){CommandLineInterface.new}

  describe '#get_matches' do
    it "yields no matches for this example user input" do
      ex_formats = ["tv series"]
      ex_genres = ["animation"]
      ex_plot_keywords = ["aliens"]
      expect(cli.get_matches(ex_formats, ex_genres, ex_plot_keywords)).to_eq([])
    end

    it "yields more than one match for this example user input" do
      ex_formats = ["tv series"]
      ex_genres = ["adventure"]
      ex_plot_keywords = ["time travel"]
      expect(cli.get_matches(ex_formats, ex_genres, ex_plot_keywords).size >= 0)
    end
  end
end

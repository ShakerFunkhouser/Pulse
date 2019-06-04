require 'nokogiri'
require 'open-uri'
require 'pry'
require_relative "../lib/entertainment_product.rb"

class Scraper

  attr_accessor :genres, :formats, :format_text_and_search_value_hash
  #SEARCH_DEPTH = 5

  def initialize
    @genres = scrape_genres
    @formats, @format_text_and_search_value_hash = scrape_title_types
    @search_depth = 5
  end

  def scrape_title_types
    text_choices = []
    search_values = []
    search_page = "https://www.imdb.com/search/title"
    html = Nokogiri::HTML(open(search_page))
    text_table = html.css("div.inputs table")[0].css("tbody tr td label")
    search_value_table = html.css("div.inputs table")[0].css("tbody tr td input")
    text_and_search_value_hash = {}

    text_table.each {|cell| text_choices << cell.text.downcase}

    search_value_table.each {|cell| search_values << cell['value']}

    for i in 0..text_choices.size
      text_and_search_value_hash[text_choices[i]] = search_values[i]
    end

    return text_choices, text_and_search_value_hash
  end

  def scrape_genres
    table_contents = []
    search_page = "https://www.imdb.com/search/title"
    html = Nokogiri::HTML(open(search_page))
    table = html.css("div.inputs table")[1].css("tbody tr td label")

    table.each do |cell|
      table_contents << cell.text.downcase
    end

    table_contents
  end

  def generate_search_url(title_types, genres, plot_keywords)
    search_page = "https://www.imdb.com/search/title?"
    if !title_types.empty?
      search_page << "title_type="
      append_search_keywords_to_url(search_page, title_types, true, "_")
    end

    if genres.size > 0
      search_page << "genres="
      append_search_keywords_to_url(search_page, genres, false, "-")
    end

    if plot_keywords.size > 0
      search_page << "keywords="
      append_search_keywords_to_url(search_page, plot_keywords, false, "+")
    end
    search_page.chomp(",")
  end

  def append_search_keywords_to_url(url, keywords, are_title_types, space_replacer)
    keywords.each do |keyword|
      search_keyword = keyword
      #if these are title types (formats), get the search value
      #associated with the user's choice
      search_keyword = @format_text_and_search_value_hash[keyword] if are_title_types
      #replace spaces and dashes with "_"
      url << "#{search_keyword = keyword.tr(" ", space_replacer)},"
    end
    url.chomp(",")
  end

  def scrape_user_search_url(url)
    matches = []
    html = Nokogiri::HTML(open(url))
    search_results = html.css("div.lister-item-content")[0..@search_depth]
    search_results.each do |search_result|
      link = "https://www.imdb.com"
      link << search_result.css("h3 a").attr("href")
      matches << scrape_imdb_title_url(link)
    end

    matches
  end

  def scrape_imdb_title_url(url)
    html = Nokogiri::HTML(open(url))
    subtext = html.css("div.title_wrapper div.subtext")

    #scraping genre names
    genres = []
    subtext_links = subtext.css("a")
    for i in 0..subtext_links.size - 1
      genres << subtext_links[i].text.split(" (")[0]
    end

    #scraping plot keywords
    plot_keywords = []
    spans = html.css("span.itemprop")
    spans.each do |span|
      plot_keywords << span.text.strip
    end

    args = {
      title: html.css("div#ratingWidget p strong").text,
      imdb_rating: html.css("div#ratingWidget span.rating").text,
      rating: subtext.text.strip[0],
      runtime: subtext.css("time").text.strip,
      genres: genres,
      release_date: subtext_links[subtext_links.size - 1].text,
      plot_summary: html.css("div.summary_text").text.strip,
      plot_keywords: plot_keywords
    }

    EntertainmentProduct.new(args)
  end

  def create_entertainment_product
    scraped_product = {}
    html = File.read(profile_url)
    profile_page = Nokogiri::HTML(html)
    social_media = profile_page.css("div.social-icon-container a")
    possible_sites = ["linkedin", "github", "twitter"]
    social_media.each do |site|
      site_link = site['href']
      #if the site name starts with "www.":
      site_name = site_link[/#{"www."}(.*?)#{".com"}/m, 1]
      #binding.pry
      if site_name == nil
        #if the site name starts with "https://" or even "//":
        site_name = site_link[/#{"\/\/"}(.*?)#{".com"}/m, 1]
      end
      if !possible_sites.include?(site_name)
        #if this is a blog, this conditional should evaluate to true,
        #in which case, we must set the key to "blog"
        site_name =  "blog"
      end
      #binding.pry
      scraped_student[site_name.to_sym] = site_link
    end

    profile_quote = profile_page.css("div.vitals-text-container div.profile-quote").text
    bio = profile_page.css("div.details-container p").text

    scraped_student[:profile_quote] = profile_quote
    scraped_student[:bio] = bio
    scraped_student
  end
end

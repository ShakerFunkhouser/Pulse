require 'open-uri'
require 'pry'
require_relative "../lib/entertainment_product.rb"

class Scraper

  def scrape_title_types
    scrape_table(0)
  end

  def scrape_genres
    scrape_table(1)
  end

  def scrape_table(table_number)
    table_contents = []
    search_page = "https://www.imdb.com/search/title"
    html = Nokogiri::HTML(open(search_page))
    table = html.css("div.inputs table")[table_number].css("tbody tr td label")

    table.each do |cell|
      table_contents << cell.text.downcase
    end

    table_contents
  end

  def generate_search_url(title_types, genres, plot_keywords)
    search_page = "https://www.imdb.com/search/title?"
    if !title_types.empty?
      search_page << "title_type="
      append_search_keywords_to_url(search_page, title_types)
    end

    if genres.size > 0
      append_search_keywords_to_url(search_page, genres)
    end

    if plot_keywords.size > 0
      append_search_keywords_to_url(search_page, plot_keywords)
    end
    search_page
  end

  def append_search_keywords_to_url(url, keywords)
    keywords.each do |keyword|
      url << "#{keyword},"
    end
    url.chomp(",")
  end

  def scrape_user_search_url(url)
    matches = []
    search_results = ulr.css("div.lister-item-content")
    search_results.each do |search_result|
      link = "https://www.imdb.com"
      link << search_result.css("h3 a").attr("href")
      matches << scrape_imdb_title_url(link)
    end

    matches
  end

  def scrape_imdb_title_url(url)
    subtext = url.css("div.title_wrapper div.subtext")

    #scraping genre names
    genres = []
    subtext_links = subtext.css("a")
    for i in 0..subtext_links.size - 1
      genres << subtext_links[i].text
    end

    #scraping plot keywords
    plot_keywords = []
    spans = url.css("span.itemprop")
    plot_keyword_spans.each do |span|
      plot_keywords << span.text.strip
    end

    {
      title: url.css("div#ratingWidget p strong").text,
      imdb_rating: url.css("div#ratingWidget span.rating").text,
      rating: subtext.text.strip[0],
      runtime: subtext.css("time").text.strip,
      genres: genres,
      release_date: subtext_links[subtext_links.size - 1].text,
      plot_summary: url.css("div.summary_text").text.strip,
      plot_keywords: plot_keywords
    }
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

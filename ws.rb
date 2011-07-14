#!/usr/bin/env ruby

require 'ruby-debug'
require 'mechanize'
require 'trollop'

class WallbaseScraper
  attr_accessor :agent

  class Album
    attr_accessor :name, :url
    def initialize(name, url)
      @name, @url = name, url
    end

    def to_s
      "#{@name}\n\t#{@url}"
    end
  end

  def initialize
    @agent ||= Mechanize.new

    url = 'http://wallbase.cc/user/login_form'
    page = @agent.get(url)

    form = page.form_with(:action => 'http://wallbase.cc/user/login')

    form.username = 'jg'
    form.pass = 'eephaix8'

    form.submit
  end

  def page_url(id)
    "http://wallbase.cc/wallpaper/#{id}"
  end

  def image_url(id)
  end

  # Returns array of Album objects 
  def albums
    albums = []
    albums << Album.new('Home', 'http://wallbase.cc/user/favorites/-1')

    url = 'http://wallbase.cc/user/favorites/0'
    page = @agent.get(url)

    regexp = /<li class=\"sortable\".+?<a href=\"(.+?)\".+?<\/span>(.+?)<\/a>/
    page.body.scan(regexp).each do |result|
      albums << Album.new(result[1], result[0])
    end
      
    return albums
  end

  # Returns list 
  def image_urls(url)
    page = @agent.get(url)

    urls = []
    links = page.links.select {|l| l.href =~ /wallbase.cc\/wallpaper/ } 
    links.each do |l|
      page = l.click
      url = page.image_urls().select {|e| e.match /wallbase2/ }.first
      urls << url
    end

    return urls
  end

  def agent
    @agent
  end
# images = page.images.select {|img| img.src =~ /wallbase1\.org/ }
# image_ids = images.map {|img| img.src.match(/thumb-(\d+)\.jpg/)[1]}
# puts image_ids

end


opts = Trollop::options do
  banner "Wallbase.cc CLI utility"
  opt :list_albums, "List albums", :short => 'l', :default => false
  opt :get_image_urls, "Get list of image urls for a given album", :short => 'g', :type => String
end

s = WallbaseScraper.new

if opts[:list_albums]
  puts s.albums
end

if opts[:get_image_urls]
  puts s.image_urls(opts[:get_image_urls])
end


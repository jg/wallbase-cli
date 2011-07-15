#!/usr/bin/env ruby

require 'ruby-debug'
require 'mechanize'
require 'trollop'

class WallbaseScraper
  attr_accessor :agent, :username, :password

  class Album
    attr_accessor :name, :url
    def initialize(name, url)
      @name, @url = name, url
    end

    def to_s
      "#{@name}\n\t#{@url}"
    end
  end

  def initialize(username, password)
    @username, @password = username, password
  end

  def login
    url = 'http://wallbase.cc/user/login_form'
    page = agent.get(url)

    form = page.form_with(:action => 'http://wallbase.cc/user/login')

    form.username = @username
    form.pass     = @password

    form.submit
  end

  def logged_in?
    agent.cookies.to_s =~ /wallbase_session/
  end

  def page_url(id)
    "http://wallbase.cc/wallpaper/#{id}"
  end

  def image_url(id)
  end

  # Returns array of Album objects 
  def albums
    login if not logged_in?

    albums = []
    albums << Album.new('Home', 'http://wallbase.cc/user/favorites/-1')

    url = 'http://wallbase.cc/user/favorites/0'
    page = agent.get(url)

    regexp = /<li class=\"sortable\".+?<a href=\"(.+?)\".+?<\/span>(.+?)<\/a>/
    page.body.scan(regexp).each do |result|
      albums << Album.new(result[1], result[0])
    end
      
    return albums
  end

  # Returns list 
  def image_urls(url)
    login if not logged_in?

    page = agent.get(url)

    urls = []
    links = page.links.select {|l| l.href =~ /wallbase.cc\/wallpaper/ } 
    links.each do |l|
      page = l.click
      url = page.image_urls().select {|e| e.match /wallbase2/ }.first
      urls << url
    end

    return urls
  end

  def method_name
  end

  def log(txt)
    puts "#{Time.now} #{txt}" if $DEBUG
  end

  # Writes found image urls to stdout, should be quicker in conjunction
  # with eg wget
  def incremental_image_urls(url)
    log "method begin" if $DEBUG
    login if not logged_in?
    log "logged in" if $DEBUG

    page = agent.get(url)
    log "got page" if $DEBUG

    links = page.links.select {|l| l.href =~ /wallbase.cc\/wallpaper/ } 
    log "selected links" if $DEBUG
    links.each do |l|
      page = l.click
      log "clicked link" if $DEBUG
      url = page.image_urls().select {|e| e.match /wallbase2/ }.first
      puts url
    end

  end

  def agent
    @agent ||= Mechanize.new
  end

end

opts = Trollop::options do
  banner <<-EOS
    A wallbase.cc CLI utility

    Usage:
      ws.rb -u <username> -p <password> [options] 
    
    Examples:
      List albums - ws.rb -u user -p pass -l
      Get image links from album url - ws.rb -u user -p pass -g <url>

  EOS
  opt :list_albums, "List albums", :short => 'l', :default => false
  opt :get_image_urls, "Get list of image urls for a given album url", :short => 'g', :type => String
  opt :get_incremental_image_urls, "Get incremental list of image urls for a given album url", :short => 'i', :type => String
  opt :username, "Specify username", :short => 'u', :type => String, :required => true
  opt :password, "Specify password", :short => 'p', :type => String, :required => true
end

unless opts[:list_albums] || opts[:get_image_urls]
  Trollop::die "Specify an action to be performed"
  exit 1
end

s = WallbaseScraper.new(opts[:username], opts[:password])

if opts[:list_albums]
    puts s.albums
end

if opts[:get_image_urls]
  puts s.image_urls(opts[:get_image_urls])
end

if opts[:get_incremental_image_urls]
  puts s.incremental_image_urls(opts[:get_incremental_image_urls])
end

#

require 'rubygems'
require 'rexml/document'
require 'net/http'
require 'fileutils'
require 'open-uri'
require 'xmlsimple'
require 'logger'
require 'nokogiri'
require 'yaml'
class AppInfo 
  
  attr_accessor :id,:name, :package_name, :screen_shots, :company, :version, :download_url, :icon, :size, :category, :description
  def screen_shots=(options)
    @screen_shots=options
  end
  def screen_shots
    @screen_shots
  end
  def to_s
    self.name
    self.package_name
    self.screen_shots.each do |screen|
      screen
    end
  end
end

DIRECTORY = File.join(FileUtils.pwd,"AppInfos4iOS")
YAML_FILE_NAME = 'app_infos.yml'
LOG_FILE_NAME = 'app_infos.log'
SCREENSHOT_DIRECTORY = 'screen_shots'


FileUtils.mkdir_p(DIRECTORY) unless File.exist?(DIRECTORY)

FileUtils.mkdir_p(File.join(DIRECTORY,SCREENSHOT_DIRECTORY)) unless File.directory?(File.join(DIRECTORY,SCREENSHOT_DIRECTORY))

# #########################################
# change file read to any xml rss feed link.
# #########################################
url = "http://itunes.apple.com/us/rss/topalbums/limit=10/xml"
xml_data = xml_data = Net::HTTP.get_response(URI.parse(url)).body
doc =  XmlSimple.xml_in(File.read("ios.xml"))

entries = []
apps = []
File.open(File.join(DIRECTORY,YAML_FILE_NAME),"w") do |file|
  id = 0
  doc["entry"].each do |entry|
    puts "gathering application number #{id}...."
    app = AppInfo.new
    app.id = id
    screen_shots = []
    app.name = entry['im:name']
  
    app.download_url = entry['link'][0]['href']
    html_for_screen_shots = Nokogiri::HTML(open(app.download_url,'User-Agent'=>'Mozilla'),nil,'utf8') 
    app.screen_shots = {}
    screen_shot_number = 1
    html_for_screen_shots.css("img.portrait").each do |img|
      screen_shot_url = img['src']
      app.screen_shots["screen_shot#{screen_shot_number.to_s}"] = screen_shot_url
      ext = File.extname(screen_shot_url)
      dir = File.join(DIRECTORY,SCREENSHOT_DIRECTORY,app.id.to_s)
      unless File.directory?(dir)
        FileUtils.mkdir_p(dir)
      end
      File.open(File.join(DIRECTORY,SCREENSHOT_DIRECTORY,app.id.to_s,"#{screen_shot_number.to_s}#{ext}"), "wb") { |s|
        res = Net::HTTP.get(URI.parse(screen_shot_url))
        s.write(res)
       }
      screen_shot_number+=1
    end
    app.description = entry['summary']
    app.company = entry['rights']
  
    icon_url = entry['link'][1]['href']
    app.icon = icon_url
    ext = File.extname(icon_url) 
  
    apps << app
    id += 1
  end
  
  YAML.dump(apps,file)
end
# puts apps.first.screen_shots.first


# $KCODE = 'u'
require 'yaml'
require 'cgi'
require 'iconv'
require 'fileutils'
class AppInfo 
  
  DIRECTORY = File.join(FileUtils.pwd,"AppInfos4IOS")
  YAML_FILE_NAME = 'app_infos.yml'
  LOG_FILE_NAME = 'app_infos.log'
  SCREENSHOT_DIRECTORY = 'screen_shots'
  
  attr_accessor :id, :name, :package_name, :screen_shots, :company, :version, :download_url, :icon, :size, :category, :description

  @@app_infos = []

  def self.load_datas
    File.open( File.join(DIRECTORY,YAML_FILE_NAME) ) do |file|
        YAML.load_documents( file ) do |doc|
          doc.each do |app|
            @@app_infos << app
          end
        end
    end
  end
  
  def self.find(id = nil)
    self.load_datas
    @@app_infos.each do |app|
      if app.id == id
        return app
      end
    end
  end

  def self.all
    @@app_infos
  end  
  
  def to_s
   "Name:       #{self.name}\n
   Package_name:#{self.package_name}\n
   Screen_shots:#{self.screen_shots}\n
   Company:     #{self.company}\n
   Version:     #{self.version}\n
   Download:    #{self.download_url}\n
   Icon:        #{self.icon}\n
   Size:        #{self.size}\n
   Category:    #{self.category}\n
   Description: #{self.description}\n
   ||||||||||||||||||||||||||||||||||||||||||||||
   "
  end
end


app = AppInfo.find 3
puts app
require 'yaml'

class Configuration
  class << self
    def load
      @@config = nil
      io = File.open(File.dirname(__FILE__) + '/../config.yml')
      YAML::load_documents(io) { |doc| @@config = doc }
      raise 'Could not locate a configuration named "config.yml"' unless @@config
    end

    def [] key
      @@config[key]
    end

    def []= key, value
      @@config[key] = value
    end
  end
end

Configuration.load
@configuration = Configuration
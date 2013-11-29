module HerokuSchemas
  class SchemaCommand
    def initialize(options)
      @heroku = Heroku::API.new(:api_key => ENV['HEROKU_API_KEY'])
      @context_app = options[:context_app]
    end

    def write(string)
      puts string
    end
  end
end

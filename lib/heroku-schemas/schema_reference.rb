module HerokuSchemas
  class SchemaReference
    attr_reader :app, :database_app, :database_variable, :base_database_url, :database_url, :schema

    # String references to schemas can take the following forms:
    # my_app
    # my_app:my_schema
    # my_app:MY_DATABASE_URL:my_schema

    def initialize(options)
      defaults = {
        heroku: nil,
        string_reference: nil,
        related_apps: []
      }
      options.reverse_merge!(defaults)
      @heroku = options[:heroku]
      @string_reference = options[:string_reference]
      @related_apps = options[:related_apps]
      @database_variable = nil
      @schema = nil

      raise 'String reference not provided' if @string_reference.blank?
      configure
    end

    def configure
      refs = @string_reference.split(':')
      raise "Invalid schema reference: #{@string_reference}" unless [1, 2, 3].include?(refs.length)
      if refs.length == 1
        @app = refs.first
      elsif refs.length == 2
        @app, @schema = refs
      else
        @app, @database_variable, @schema = refs
      end

      app_variables = app_config_variables(@app)
      @database_variable ||= 'DATABASE_URL'
      @database_url = app_variables[@database_variable]
      @schema ||= SchemaUtilities.url_to_schema(@database_url)
      raise "Database URL not found for database variable #{@database_variable}" if @database_url.blank?

      validation_message = SchemaUtilities.validate_schema(@schema)
      raise validation_message if validation_message != true
      
      @database_url = @base_database_url = get_base_database_url(@database_url)
      @database_url = "#{@database_url}?schema_search_path=#{@schema}" unless @schema == 'public'

      if @database_variable == 'DATABASE_URL'
        @related_apps.each do |app|
          config_variables = app_config_variables(app)
          database_variable = find_database_variable(config_variables, @base_database_url)
          if database_variable
            @database_variable = database_variable
            @database_app = app
            break
          end
        end
      end
      raise "Database variable not found" if @database_variable.blank?
    end

    def find_database_variable(config_variables, database_url)
      standardized_database_url = get_base_database_url(database_url)
      config_variables.each do |name, value|
        next if name == 'DATABASE_URL'
        return name if get_base_database_url(value) == standardized_database_url
      end
      nil
    end

    def app_config_variables(app)
      @heroku.get_config_vars(app).body
    end

    def get_base_database_url(url)
      return nil if url.nil?
      url.split('?').first
    end

    def ==(schema_reference)
      return true if self.base_database_url == schema_reference.base_database_url &&
        self.schema == schema_reference.schema
      false
    end
  end
end

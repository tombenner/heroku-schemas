module HerokuSchemas
  class Drop < SchemaCommand
    attr_reader :database

    def initialize(options)
      super(options)

      @string_reference = options[:string_reference]
      raise 'Context app not provided' if @context_app.blank?
      raise 'Schema reference not provided' if @string_reference.blank?
      
      related_apps = [@context_app, @string_reference.split(':').first].uniq
      @schema = HerokuSchemas::SchemaReference.new(heroku: @heroku, string_reference: @context_app, related_apps: related_apps)
      @database = HerokuSchemas::CurrentDatabase.connect_to_url(@schema.database_url)
    end

    def perform
      @database.execute("DROP SCHEMA #{@schema.schema} CASCADE")
      write "Dropped schema #{@schema.database_app}:#{@schema.database_variable}:#{@schema.schema}"
    end
  end
end

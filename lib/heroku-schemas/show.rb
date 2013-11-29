module HerokuSchemas
  class Show < SchemaCommand
    attr_reader :database

    def initialize(options)
      super(options)

      @schema = HerokuSchemas::SchemaReference.new(heroku: @heroku, string_reference: @context_app, related_apps: [@context_app])
    end

    def perform
      write "Schema being used:\n#{@schema.database_app}:#{@schema.database_variable}:#{@schema.schema}"
    end
  end
end

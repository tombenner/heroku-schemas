module HerokuSchemas
  class CurrentDatabase < HerokuSchemas::Database
    class << self
      def connection_name
        'current'
      end
    end
  end
end

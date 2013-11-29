module HerokuSchemas
  class TargetDatabase < Database
    class << self
      def connection_name
        'target'
      end
    end
  end
end

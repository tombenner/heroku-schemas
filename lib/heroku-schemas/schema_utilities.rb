module HerokuSchemas
  class SchemaUtilities
    class << self
      def add_schema_search_path_to_url(url, schema)
        uri = URI(url)
        params = uri_to_params(uri)
        
        # Handle the case of poorly-formed query strings where CGI::parse turns 'pool=20?pool=20'
        # into {'pool' => ["20?pool=20"]}
        params.each do |key, value|
          if value.is_a?(Array) && value.length == 1
            params[key] = value.first.split('?').first
          end
        end
        
        params['schema_search_path'] = schema
        uri.query = params.to_query
        uri.to_s
      end

      def app_to_schema(app)
        app.downcase.gsub(/[^\w_]/, '_')
      end

      def url_to_schema(url)
        uri = URI(url)
        params = uri_to_params(uri)
        schema = params['schema_search_path'] || 'public'
        schema = schema.first if schema.is_a?(Array)
        schema
      end

      def uri_to_params(uri)
        uri.query ? CGI::parse(uri.query) : {}
      end

      def validate_schema(schema)
        if schema.blank? || schema =~ /[^a-z0-9_]/
          return "Schema must only contain lowercase letters, numbers and underscores. Provided value: #{schema}"
        end
        true
      end
    end
  end
end

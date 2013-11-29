module HerokuSchemas
  class Database < ActiveRecord::Base
    class << self
      def connect_to_url(url)
        ActiveRecord::Base.configurations[connection_name] = url_to_config(url)
        establish_connection(connection_name)
        self
      end

      def url_to_config(url)
        db = URI.parse(url)
        { 
          :adapter  => 'postgresql',
          :username => db.user,
          :password => db.password,
          :port     => db.port,
          :database => db.path.sub(%r(^/), ''),
          :host     => db.host
        }
      end

      def config_to_url(config)
        "postgres://#{config[:username]}:#{config[:password]}@#{config[:host]}:#{config[:port]}/#{config[:database]}"
      end

      def url
        config_to_url(connection.instance_variable_get(:@config))
      end

      def execute(sql)
        connection.execute(sql)
      end

      def select_values(sql)
        connection.select_values(sql)
      end

      def schema_exists?(schema)
        existing_schemas.include?(schema)
      end

      def tables_exist?(schema)
        schema_tables(schema).present?
      end

      def schema_tables(schema)
        select_values("SELECT table_name FROM information_schema.tables WHERE table_schema = '#{schema}'")
      end

      def existing_schemas
        select_values('SELECT schema_name FROM information_schema.schemata')
      end

      def create_schema(schema)
        execute("CREATE SCHEMA #{schema}")
      end

      def rename_schema(from_schema, to_schema)
        execute("ALTER SCHEMA #{from_schema} RENAME TO #{to_schema}")
      end
    end
  end
end

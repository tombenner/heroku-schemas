# Allows for manipulations of a Heroku app and its database in a testing environment
module HerokuSchemas
  module Test
    class App
      attr_reader :database, :name

      def initialize(name, database)
        @name = name
        @database = database
        @heroku = Heroku::API.new(:api_key => Configuration['heroku_api_key'])
        @dummy_app_path = File.expand_path('../../../../../spec/dummy-app', __FILE__)
        initialize_app
      end

      def initialize_app
        if app_exists?
          puts "Resetting app #{name}..."
          reset_app
        else
          puts "Creating app #{name}..."
          create_app
        end
      end

      def create_app
        begin
          @heroku.post_app('name' => name)
        rescue Heroku::API::Errors::RequestFailed
        end

        begin
          @heroku.post_addon(name, 'pgbackups:plus')
        rescue Heroku::API::Errors::RequestFailed
        end

        set_git_remote
        Dir.chdir @dummy_app_path do
          system "git push heroku master"
        end
        add_data_to_schema
      end

      def set_git_remote
        Dir.chdir @dummy_app_path do
          system "git remote set-url heroku git@heroku.com:#{name}.git"
        end
      end

      def add_data_to_schema(schema=nil)
        if schema
          original_schema_search_path = database.connection.schema_search_path
          database.connection.schema_search_path = schema
          database.execute("CREATE SCHEMA #{schema}")
        end
        app_database = database
        ActiveRecord::Schema.define do
          @connection = app_database.connection
          create_table "dummy_records", :force => true do |t|
            t.string   "name"
            t.datetime "created_at", :null => false
            t.datetime "updated_at", :null => false
          end
        end
        database.execute("INSERT INTO dummy_records (name, created_at, updated_at) VALUES ('#{name}', NOW(), NOW())")
        if schema
          database.connection.schema_search_path = original_schema_search_path
        end 
      end

      def app_exists?
        begin
          app = @heroku.get_app(name)
        rescue Heroku::API::Errors::NotFound
          return false
        end
        app
      end

      def reset_app
        database_url = reset_app_database_url
        database.connect_to_url(database_url)
        database.existing_schemas.each do |schema|
          database.execute("DROP SCHEMA #{schema} CASCADE")
        end
        database.execute('CREATE SCHEMA public')
        add_data_to_schema
      end

      # Reset DATABASE_URL to the value in the first HEROKU_POSTGRESQL_$COLOR_URL-style config variable
      def reset_app_database_url
        @heroku.get_config_vars(name).body.each do |key, value|
          if key != 'DATABASE_URL' && key.end_with?('_URL') && value.start_with?('postgres://')
            @heroku.put_config_vars(name, 'DATABASE_URL' => value)
            return value
          end
        end
      end

      def delete_app
        begin
          app = @heroku.delete_app(name)
        rescue Heroku::API::Errors::NotFound
          return false
        end
        app
      end
    end
  end
end
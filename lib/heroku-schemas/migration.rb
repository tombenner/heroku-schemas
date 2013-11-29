module HerokuSchemas
  class Migration < SchemaCommand
    attr_reader :current_schema, :current_database
    attr_reader :target_schema, :target_database
    attr_reader :backup_url, :context_app

    def initialize(options)
      super(options)
      @pgbackups = HerokuSchemas::Pgbackups.new

      @string_reference = options[:string_reference]
      raise 'Context app not provided' if @context_app.blank?
      raise 'Schema reference not provided' if @string_reference.blank?
      
      related_apps = [@context_app, @string_reference.split(':').first].uniq
      @current_schema = HerokuSchemas::SchemaReference.new(heroku: @heroku, string_reference: @context_app, related_apps: related_apps)
      @target_schema = HerokuSchemas::SchemaReference.new(heroku: @heroku, string_reference: @string_reference, related_apps: related_apps)

      @current_database = HerokuSchemas::CurrentDatabase.connect_to_url(@current_schema.database_url)
      @target_database = HerokuSchemas::TargetDatabase.connect_to_url(@target_schema.database_url)
    end

    def perform
      validate_migration
      if current_schema_has_data?
        migrate_database
      else
        update_database_url
      end
    end

    def validate_migration
      if current_schema == target_schema
        raise "App (#{context_app}) is already using the target schema (#{target_schema.base_database_url}, #{target_schema.schema})"
      end
      if target_schema_has_data?
        command = "heroku schemas:drop #{target_schema.database_app}:#{target_schema.database_variable}:#{target_schema.schema}"
        raise "Target schema (#{target_schema.base_database_url}, #{target_schema.schema}) already contains data. Please drop it before proceding by running:\n`#{command}`"
      end
    end

    def current_schema_has_data?
      current_database.existing_schemas.include?(current_schema.schema) && current_database.tables_exist?(current_schema.schema)
    end

    def target_schema_has_data?
      target_database.existing_schemas.include?(target_schema.schema) && target_database.tables_exist?(target_schema.schema)
    end

    def is_migrated?
      target_database.existing_schemas.include?(target_schema.schema)
    end

    def migrate_database
      create_backup_with_target_schema
      update_database_url
      create_target_schema_in_target_database
      import_backup_into_target_database
    end

    def create_backup_with_target_schema
      write 'Creating database backup...'
      current_database.rename_schema(current_schema.schema, target_schema.schema)
      @backup_url = create_backup(current_schema.database_app, current_schema.database_variable)
      current_database.rename_schema(target_schema.schema, current_schema.schema)
    end

    def create_target_schema_in_target_database
      target_database.create_schema(target_schema.schema)
    end

    def import_backup_into_target_database
      write 'Restoring database backup...'
      restore_from_backup_url
    end

    # Point DATABASE_URL to the target app's DATABASE_URL, but with the new schema_search_path
    def update_database_url
      target_database_url = SchemaUtilities.add_schema_search_path_to_url(target_schema.database_url, target_schema.schema)
      set_app_database_url(context_app, target_database_url)
    end

    def create_backup(app, database_variable)
      args = [database_variable, '--app', app, '--expire'].compact
      # args = ['HEROKU_POSTGRESQL_CYAN_URL', '--app', 'tom-target-app', '--expire'].compact

      # @pgbackups.app = app
      # @pgbackups.capture(database_variable, expire: true)
      Heroku::Command.run('pgbackups:capture', args)

      @pgbackups.app = app
      @pgbackups.latest_backup_url
    end

    def restore_from_backup_url
      args = [target_schema.database_variable, backup_url, '--app', target_schema.database_app, '--confirm', target_schema.database_app]
      Heroku::Command.run('pgbackups:restore', args)
    end

    def app_database_url(app)
      vars = @heroku.get_config_vars(app).body
      vars['DATABASE_URL']
    end

    def set_app_database_url(app, url)
      @heroku.put_config_vars(app, 'DATABASE_URL' => url)
    end
  end
end

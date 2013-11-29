Given /^two apps named '([\w_-]+)' and '([\w_-]+)'$/ do |current_app, target_app|
  @configuration = Configuration
  @heroku = Heroku::API.new(:api_key => @configuration['heroku_api_key'])

  prefix = @configuration['heroku_app_prefix']
  current_app_name = "#{prefix}#{current_app}"
  target_app_name = "#{prefix}#{target_app}"

  @current_app = HerokuSchemas::Test::App.new(current_app_name, HerokuSchemas::CurrentDatabase)
  @target_app = HerokuSchemas::Test::App.new(target_app_name, HerokuSchemas::TargetDatabase)
  
  @current_schema = 'public'
  @target_schema = HerokuSchemas::SchemaUtilities.app_to_schema(current_app_name)
  @migration = HerokuSchemas::Migration.new(
    context_app: current_app_name,
    string_reference: "#{target_app_name}:#{@target_schema}"
  )
end

And /^I add the current app's schema to the target app's database$/ do
  @target_app.add_data_to_schema(@target_schema)
end

And /^I create a backup with the target schema$/ do
  @migration.create_backup_with_target_schema
  @migration.backup_url.should =~ %r|^https://.+\.dump.+$|
end

And /^I update the database URL$/ do
  @migration.update_database_url
end

And /^I create the target schema$/ do
  @migration.create_target_schema_in_target_database
  @migration.target_database.existing_schemas.should =~ ['public', @target_schema]
end

And /^I import the backup into the target schema$/ do
  @migration.import_backup_into_target_database
end

And /^I run the migration$/ do
  begin
    @migration.perform
  rescue Exception => @error
  end
end

Then /an error containing "(.+)" is raised/ do |message_excerpt|
  @error.should_not be_nil
  @error.message.should include(message_excerpt)
end

Then /^the first app should be using the database of the second app$/ do
  @migration.target_database.schema_tables(@target_schema).should =~ ['dummy_records']
  @migration.target_database.select_values("SELECT dummy_records.name FROM #{@target_schema}.dummy_records").should == [@current_app.name]
end

Given /^an app named '([\w_-]+)'$/ do |app|
  @configuration = Configuration
  @heroku = Heroku::API.new(:api_key => @configuration['heroku_api_key'])

  prefix = @configuration['heroku_app_prefix']
  app_name = "#{prefix}#{app}"
  @app = HerokuSchemas::Test::App.new(app_name, HerokuSchemas::CurrentDatabase)
end

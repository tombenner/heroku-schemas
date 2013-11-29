require 'spec_helper'

describe HerokuSchemas::SchemaUtilities do
  let(:klass) { HerokuSchemas::SchemaUtilities }
  let(:database_url) { 'postgres://user:pass@host:1234/database' }

  describe '.add_schema_search_path_to_url' do
    it 'adds schema_search_path if it is not present' do
      klass.add_schema_search_path_to_url(database_url, 'my_schema').should == "#{database_url}?schema_search_path=my_schema"
    end

    it 'updates schema_search_path if it is present' do
      klass.add_schema_search_path_to_url("#{database_url}?schema_search_path=foo", 'my_schema').should == "#{database_url}?schema_search_path=my_schema"
    end
  end

  describe '.app_to_schema' do
    it 'transforms a hyphenated app name to a valid schema' do
      klass.app_to_schema('my-app').should == 'my_app'
    end
  end

  describe '.url_to_schema' do
    it 'returns the public schema if a schema is not present' do
      klass.url_to_schema(database_url).should == 'public'
    end

    it 'returns the schema if a schema is present' do
      klass.url_to_schema("#{database_url}?schema_search_path=my_schema&foo=bar").should == 'my_schema'
    end

    it 'returns the schema if the query string has two question marks' do
      klass.url_to_schema("#{database_url}?pool=20?pool=20&schema_search_path=my_schema").should == 'my_schema'
    end
  end

  describe '.validate_schema' do
    it 'returns true if the schema is valid' do
      klass.validate_schema('my_schema').should be_true
    end

    it 'returns a message if the schema is not valid' do
      klass.validate_schema('my-schema').should include('Schema must only contain lowercase letters, numbers and underscores.')
    end
  end
end
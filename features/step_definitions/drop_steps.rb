And /^I drop the schema named '(.+)'$/ do |schema|
  @schema = schema
  @drop = HerokuSchemas::Drop.new(
    context_app: @app.name,
    string_reference: "#{@app.name}:#{@schema}"
  )
  @drop.perform
end

Then /^no schemas should exist$/ do
  @drop.database.existing_schemas.should be_empty
end

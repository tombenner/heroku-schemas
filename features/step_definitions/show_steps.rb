And /^I run the show command$/ do
  @show = HerokuSchemas::Show.new(
    context_app: @app.name
  )
  @buffer = OutputBuffer.new.activate
  @show.perform
  @buffer.stop
end

Then /^the output should match '(.+)'$/ do |regex|
  @buffer.to_s.should match(/#{regex}/)
end

module Heroku
  module Command
    class Schemas < Base
      def index
        command = HerokuSchemas::Migration.new(
          context_app: app,
          string_reference: shift_argument
        )
        command.perform
      end

      def drop
        command = HerokuSchemas::Drop.new(
          context_app: app,
          string_reference: shift_argument
        )
        command.perform
      end

      def show
        command = HerokuSchemas::Show.new(
          context_app: app
        )
        command.perform
      end
    end
  end
end

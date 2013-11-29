require 'heroku/command/pgbackups'

module HerokuSchemas
  class Pgbackups < Heroku::Command::Pgbackups
    attr_accessor :app, :args
    
    def validate_arguments!
    end

    def latest_backup
      pgbackup_client.get_latest_backup
    end

    def latest_backup_url
      latest_backup['public_url']
    end
  end
end

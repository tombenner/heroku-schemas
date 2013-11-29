require 'active_record'
require 'active_support/core_ext'
require 'heroku-api'

require 'heroku-schemas/database'
require 'heroku-schemas/current_database'
require 'heroku-schemas/target_database'

require 'heroku-schemas/schema_command'
require 'heroku-schemas/drop'
require 'heroku-schemas/migration'
require 'heroku-schemas/show'

require 'heroku-schemas/pgbackups'
require 'heroku-schemas/schema_reference'
require 'heroku-schemas/schema_utilities'
require 'heroku-schemas/version'
require 'heroku/command/base'
require 'heroku/command/schemas'

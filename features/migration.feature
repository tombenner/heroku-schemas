Feature: Migration
  In order to move an app's database
  A developer
  Should be able to run a migration

  Scenario: App has not been migrated
    Given two apps named 'current-app' and 'target-app'
    And I create a backup with the target schema
    And I create the target schema
    And I update the database URL
    And I import the backup into the target schema
    Then the first app should be using the database of the second app

  Scenario: App has been migrated
    Given two apps named 'current-app' and 'target-app'
    And I add the current app's schema to the target app's database
    And I run the migration
    Then an error containing "already contains data" is raised
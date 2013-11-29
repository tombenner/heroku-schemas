Feature: Drop
  In order to drop a schema
  A developer
  Should be able to run a command

  Scenario: App has been initialized
    Given an app named 'current-app'
    And I drop the schema named 'public'
    Then no schemas should exist

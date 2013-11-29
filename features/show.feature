Feature: Show
  In order to see what schema an app is using
  A developer
  Should be able to run a command

  Scenario: App has been initialized
    Given an app named 'current-app'
    And I run the show command
    Then the output should match 'current-app:[A-Z_]+:public'

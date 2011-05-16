@wip
Feature: List studies

In order to understand what templates are available
A developer should be able to use Psc::Client to list the studies in a PSC instance

Background:
  Given that PSC is deployed
    And I have a PSC::Client instance

Scenario: List studies
   When I evaluate the following code:
    """
    s = client.studies
    puts "Study count: #{s.size}"
    puts "First study: #{s.first['assigned_identifier']}"
    """
   Then I should see this output:
    """
    Study count: 1
    First study: ABC 1200
    """


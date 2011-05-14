@wip
Feature: List studies

In order to understand what templates are available
A developer should be able to use Psc::Client to list the studies in a PSC instance

Background:
  Given that PSC is deployed
    And I have a PSC::Client instance

Scenario: List studies
   When I evaluate `client.studies`
   Then I should receive objects like the following:
    """
    [
      {
        'assigned_identifier': 'ABC 1200'
      }
    ]
    """

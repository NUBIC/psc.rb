Given /^that PSC is deployed$/ do
  int_psc.boot
end

Given /^I have a PSC::Client instance$/ do
  init_client
end

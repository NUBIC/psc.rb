When /^I evaluate the following code:$/ do |string|
  int_psc.wait_for
  @captured_out = StringIO.new
  begin
    $stdout = @captured_out
    eval(string)
  ensure
    $stdout = STDOUT
  end
end

Then /^I should see this output:$/ do |string|
  @captured_out.string.strip.should == string
end

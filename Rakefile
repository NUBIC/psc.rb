require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
require 'ci/reporter/rake/rspec'
require 'cucumber/rake/task'
require 'yard'

Dir[File.expand_path('../tasks/*.rake', __FILE__)].each { |f| load f }

desc "Run all specs"
RSpec::Core::RakeTask.new('spec') do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = true
  t.rspec_opts = ['--format', 'html', '--out', 'reports/spec.html', '--format', 'p']
end

task :cucumber => 'cucumber:ok'

namespace :cucumber do
  Cucumber::Rake::Task.new(:ok, "Run features that should pass") do |t|
    t.fork = true
    t.profile = "default"
  end

  Cucumber::Rake::Task.new(:wip, "Run features that are being worked on") do |t|
    t.fork = true
    t.profile = "wip"
  end

  Cucumber::Rake::Task.new(
    :wip_platform, "Run features that are flagged as failing on the current platform"
  ) do |t|
    t.fork = true
    t.profile = "wip_platform"
  end

  desc "Run all features"
  task :all => [:ok, :wip, :wip_platform]
end

task :yard => ['yard:auto']

namespace :yard do
  desc "Run a server which will rebuild documentation as the source changes"
  task :auto do
    system("bundle exec yard server --reload")
  end

  desc "Build API documentation with yard"
  YARD::Rake::YardocTask.new("once") do |t|
    t.options = ["--title", "psc.rb #{Psc::VERSION}"]
  end
end

namespace :ci do
  ENV["CI_REPORTS"] = "reports/spec-xml"

  desc "Run specs for CI"
  task :spec => ['ci:setup:rspec', 'rake:spec']

  Cucumber::Rake::Task.new(:cucumber, 'Run features using the ci profile') do |t|
    t.fork = true
    t.profile = 'ci'
  end

  # currently bypassing ci_reporter due to https://github.com/nicksieger/ci_reporter/issues/5
  task :build => %w(int-psc:unlock_database int-psc:war int-psc:clean_logs rake:spec cucumber)
end

require 'childprocess'
require 'open-uri'
require 'timeout'
require 'faraday'

require File.expand_path('../psc/state.rb', __FILE__)

module IntPsc
  def self.path(*bits)
    File.join(File.expand_path('../..', __FILE__), 'int-psc', *bits)
  end

  def self.port
    ENV['INT_PSC_PORT'] ||= '7209'
  end

  def self.url
    "http://localhost:#{port}/"
  end

  def self.warfile
    path('bin', 'psc.war')
  end

  def self.boot_int_psc(configuration='datasource')
    mkdir_p path('deploy-base')
    cmd = [
      'java',
      ENV['JAVA_OPTS'],
      "-Dpsc.config.datasource=#{configuration}",
      "-Dpsc.config.path=#{path}",
      '-Dpsc.logging.debug=true',
      "-Dcatalina.base=#{path 'deploy-base'}",

      '-jar',
      # jetty-runner
      path('jetty', 'jetty-runner-7.4.0.v20110414.jar'),
      "--port", port,
      warfile
    ].compact

    @running_psc = ChildProcess.build(*cmd)
    @running_psc.duplex = true
    @running_psc.io.inherit!

    at_exit { @running_psc.stop if @running_psc.alive? }
    @running_psc.start
    @running_psc.io.stdin.close # to turn off ShellTUI for the OSGi layer
  end

  def self.stop_int_psc
    @running_psc.stop
  end

  def self.wait_for_int_psc
    puts "Waiting for PSC's API to become available"
    Timeout.timeout(90) do
      while true
        begin
          open(File.join(self.url, '/api/v1/docs')) { |f| f.read }
          break
        rescue RuntimeError
          sleep(1)
        rescue
          sleep(1)
        end
      end
    end
    puts "API ready"
  end

  def self.create_hsql_psc_configuration(name)
    File.open(path("#{name}.properties"), 'w') do |f|
      f.puts [
        "datasource.url=jdbc:hsqldb:file:#{path('hsqldb', name)};shutdown=true",
        'datasource.username=sa',
        'datasource.password=',
        'datasource.driver=org.hsqldb.jdbcDriver'
      ].join("\n")
    end
  end

  def self.apply_state_and_mark_readonly
    client = Faraday.new(File.join(url, '/api/v1')) do |builder|
      builder.adapter :net_http
    end
    client.basic_auth('superuser', 'superuser')
    Psc::State.from_file(path('state/int-psc-state.xml')).apply(client)

    File.open(path('hsqldb', 'datasource.properties'), 'a') do |f|
      f.puts 'hsqldb.files_readonly=true'
    end
  end
end

namespace 'int-psc' do
  desc 'Ensure a psc.war is available for tests. Downloads the latest nightly if not.'
  task :war => IntPsc.warfile

  namespace :war do
    directory IntPsc.path('downloads')

    file IntPsc.path('downloads', 'archive.zip') => IntPsc.path('downloads') do |task|
      sh [
        'curl',
        '-o', task.name,
        "'https://ctms-ci.nubic.northwestern.edu/hudson/job/PSC%20nightly%20distribution/lastSuccessfulBuild/artifact/*zip*/archive.zip'"
      ].join(' ')
    end

    file IntPsc.warfile do
      # only download if a psc.war wasn't separately provided
      task(IntPsc.path('downloads', 'archive.zip')).invoke

      cd IntPsc.path('downloads') do
        sh "unzip -o archive.zip"
        distpkg = Dir['archive/psc/target/artifacts/psc*.zip'].first
        fail "No dist package in downloaded archive" unless distpkg
        sh "unzip -o '#{distpkg}'"
        pkgwar = Dir['psc-*/psc.war'].first
        fail "No war in dist package" unless pkgwar

        mkdir_p File.dirname(IntPsc.warfile)
        cp pkgwar, IntPsc.warfile
      end
    end
  end

  task :clean_baseline do
    rm_rf IntPsc.path('baseline.properties')
    rm_rf IntPsc.path('hsqldb')
  end

  task :create_baseline_config do |t|
    IntPsc.create_hsql_psc_configuration('baseline')
  end

  task :recreate_baseline => [IntPsc.warfile, :clean_baseline, :create_baseline_config] do
    IntPsc.boot_int_psc('baseline')
    IntPsc.wait_for_int_psc
    puts
    puts "Please run through PSC's setup flow and create an all-powerful user with the"
    puts "credentials superuser/superuser. PSC is running at"
    puts
    puts "  #{IntPsc.url}"
    puts
    puts "When complete, come back here and press any key."
    puts
    STDIN.getc
    IntPsc.stop_int_psc
  end

  task :clean_datasource do
    cd IntPsc.path('hsqldb') do
      Dir['baseline.*'].each { |fn| cp fn, fn.sub(/^baseline/, 'datasource') }
    end
  end

  task :create_datasource_config do |t|
    IntPsc.create_hsql_psc_configuration('datasource')
  end

  desc 'Recreate the PSC integrated test instance from the state data in int-psc/state'
  task :rebuild => [IntPsc.warfile, :clean_datasource, :create_datasource_config] do
    IntPsc.boot_int_psc
    IntPsc.wait_for_int_psc
    IntPsc.apply_state_and_mark_readonly
    IntPsc.stop_int_psc
  end

  desc 'Start up the integrated test PSC instance to poke around'
  task :examine do
    IntPsc.boot_int_psc
    IntPsc.wait_for_int_psc
    puts "Integrated test PSC running at #{IntPsc.url}.\nPress any key to shut down."
    STDIN.getc
    IntPsc.stop_int_psc
  end
end

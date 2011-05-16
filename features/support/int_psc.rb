# Utilities for starting and stopping a PSC instance for integration testing

require 'childprocess'
require 'open-uri'
require 'timeout'
require 'forwardable'
require 'fileutils'

class IntPsc
  DEFAULT_CONFIGURATION_NAME='datasource'

  extend Forwardable
  include FileUtils

  def self.path(*bits)
    File.join(File.expand_path('../../..', __FILE__), 'int-psc', *bits)
  end
  def_delegator self, :path

  def self.port
    ENV['INT_PSC_PORT'] ||= '7209'
  end
  def_delegator self, :port

  def self.url
    "http://localhost:#{port}/"
  end
  def_delegator self, :url

  def self.warfile
    path('bin', 'psc.war')
  end
  def_delegator self, :warfile

  def self.expanded_war_directory
    path('deploy-base', 'webapps', 'ROOT')
  end
  def_delegator self, :expanded_war_directory

  def self.run(configuration=DEFAULT_CONFIGURATION_NAME)
    psc = self.new(configuration)
    psc.boot
    psc.wait_for
    yield psc
    psc.stop
  end

  attr_reader :configuration_name

  def initialize(configuration=DEFAULT_CONFIGURATION_NAME)
    @configuration_name = configuration
  end

  def boot
    expand_if_necessary

    mkdir_p path('deploy-base')
    cmd = [
      'java',
      ENV['JAVA_OPTS'],
      "-Dpsc.config.datasource=#{configuration_name}",
      "-Dpsc.config.path=#{path}",
      '-Dpsc.logging.debug=true',
      "-Dcatalina.base=#{path 'deploy-base'}",

      '-jar',
      # jetty-runner
      path('jetty', 'jetty-runner-7.4.0.v20110414.jar'),
      "--port", port,
      expanded_war_directory
    ].compact

    @running_psc = ChildProcess.build(*cmd)
    @running_psc.duplex = true
    @running_psc.io.inherit!

    at_exit { @running_psc.stop if @running_psc.alive? }
    @running_psc.start
    @running_psc.io.stdin.close # to turn off ShellTUI for the OSGi layer
  end

  def stop
    @running_psc.stop if @running_psc
  end

  def wait_for
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

  def create_hsql_psc_configuration
    File.open(path("#{configuration_name}.properties"), 'w') do |f|
      f.puts [
        "datasource.url=jdbc:hsqldb:file:#{path('hsqldb', configuration_name)};shutdown=true",
        'datasource.username=sa',
        'datasource.password=',
        'datasource.driver=org.hsqldb.jdbcDriver'
      ].join("\n")
    end
  end

  def apply_state_and_mark_readonly
    client = Faraday.new(File.join(url, '/api/v1')) do |builder|
      builder.adapter :net_http
    end
    client.basic_auth('superuser', 'superuser')
    Psc::State.from_file(path('state/int-psc-state.xml')).apply(client)

    File.open(path('hsqldb', "#{configuration_name}.properties"), 'a') do |f|
      f.puts 'hsqldb.files_readonly=true'
    end
  end

  def expand_if_necessary
    dirtime = File.directory?(expanded_war_directory) ?
      File.mtime(expanded_war_directory) :
      Time.at(0)
    wartime = File.mtime(warfile)
    if wartime > dirtime
      rm_rf expanded_war_directory
      mkdir_p expanded_war_directory
      cd expanded_war_directory do
        system("jar xf '#{warfile}'")
      end
    end
  end
end


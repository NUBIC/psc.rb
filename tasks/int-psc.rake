require 'faraday'

require File.expand_path('../psc/state.rb', __FILE__)
require File.expand_path('../../features/support/int_psc.rb', __FILE__)

namespace 'int-psc' do
  desc 'Ensure a psc.war is available for tests. Downloads the latest nightly if not.'
  task :war => IntPsc.warfile

  namespace :war do
    directory IntPsc.path('downloads')

    file IntPsc.path('downloads', 'archive.zip') => IntPsc.path('downloads') do |task|
      sh [
        'curl',
        '-o', task.name,
        "'https://ctms-ci.nubic.northwestern.edu/job/PSC%20nightly%20distribution/lastSuccessfulBuild/artifact/*zip*/archive.zip'"
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
    rm_rf IntPsc.path('hsqldb')
  end

  task :recreate_baseline => [IntPsc.warfile, :clean_baseline] do
    IntPsc.run('baseline') do
      puts
      puts "Please run through PSC's setup flow and create an all-powerful user with the"
      puts "credentials superuser/superuser. PSC is running at"
      puts
      puts "  #{IntPsc.url}"
      puts
      puts "When complete, come back here and press any key."
      puts
      STDIN.getc
    end
  end

  task :clean_datasource do
    cd IntPsc.path('hsqldb') do
      Dir['baseline.*'].each { |fn| cp fn, fn.sub(/^baseline/, 'datasource') }
    end
  end

  desc 'Recreate the PSC integrated test instance from the state data in int-psc/state'
  task :rebuild => [IntPsc.warfile, :clean_datasource] do
    IntPsc.run do |int_psc|
      int_psc.apply_state_and_mark_readonly
    end
    # the copied log file is not needed in the locked database
    rm path('hsqldb', 'datasource.log')
  end

  desc 'Start up the integrated test PSC instance to poke around'
  task :examine do
    IntPsc.run do
      puts "Integrated test PSC running at #{IntPsc.url}.\nPress any key to shut down."
      STDIN.getc
    end
  end

  desc 'Purge the logs for the integration test PSC instance'
  task :clean_logs do
    rm_rf IntPsc.path('deploy-base', 'logs')
  end
end

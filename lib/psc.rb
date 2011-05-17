require 'builder'

module Psc
  autoload :Faraday,    'psc/faraday'
  autoload :Client,     'psc/client'
  autoload :Connection, 'psc/connection'

  ##
  # Wraps `Builder::XmlMarkup` to ease the construction of PSC XML
  # entities. For example:
  #
  #     Psc.xml('study-snapshot', :assigned_identifier => 'YUV 1234') do |snap|
  #       snap.tag!('long-title', 'Why you validly counting?')
  #       snap.tag!('planned-calendar') { |pc|
  #         pc.epoch(:name => 'Run-in') { |e|
  #           # and so on
  #         }
  #       }
  #       snap.sources { |sources|
  #         sources.source { |src|
  #           # and so on
  #         }
  #       }
  #     }
  #
  # @see http://builder.rubyforge.org/classes/Builder/XmlMarkup.html
  # @return [String]
  def self.xml(root_name, root_attributes={}, &block)
    root_attributes['xmlns'] = xml_namespace['psc']
    Builder::XmlMarkup.new(:indent => 2).tag!(root_name, root_attributes, &block)
  end

  ##
  # Provides an XML namespace mapping suitable for use with
  # Nokogiri. The prefix `psc` is mapped to PSC's namespace.
  #
  # @return [Hash<String, String>]
  def self.xml_namespace
    { 'psc' => 'http://bioinformatics.northwestern.edu/ns/psc' }
  end
end

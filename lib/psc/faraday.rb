require 'psc'

require 'faraday'

module Psc::Faraday
  autoload :HttpBasic,   'psc/faraday/http_basic'
  autoload :PscToken,    'psc/faraday/psc_token'
  autoload :StringIsXml, 'psc/faraday/string_is_xml'
end

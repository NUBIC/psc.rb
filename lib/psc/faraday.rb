require 'psc'

require 'faraday'

##
# The custom Faraday middleware used in `psc.rb`.
module Psc::Faraday
  autoload :HttpBasic,   'psc/faraday/http_basic'
  autoload :PscToken,    'psc/faraday/psc_token'
  autoload :StringIsXml, 'psc/faraday/string_is_xml'
end

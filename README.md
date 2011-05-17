(Beware: [Readme-driven development in
progress](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html). This
is documentation for expected features, not for the current state of
the library.)

# psc.rb

`psc.rb` is a ruby client for [Patient Study Calendar][psc]'s RESTful
HTTP API. It provides assistance with authentication to PSC's API and
with executing common tasks. It also provides a lower-level interface
(`Psc::Connection`) to allow for making HTTP requests against the
configured PSC's API directly.

By design, the client provides a very thin abstraction over the API
itself. Please be familiar with the API (whose documentation is
available in your PSC instance at `api/v1/docs` or [on the demo
site][demo-docs]) before using this library.

[psc]: https://code.bioinformatics.northwestern.edu/issues/wiki/psc
[demo-docs]: https://demos.nubic.northwestern.edu/psc/api/v1/docs

## Overview

    require 'psc'
    require 'pp'

    psc = Psc::Client.new(
      'https://demos.nubic.northwestern.edu/psc',
      :authenticator => { :basic => ['superuser', 'superuser'] }
    )

    pp psc.studies

(This code will run if you have the psc gem installed; try it and see.)

## Installing

`psc.rb` is available as a rubygem:

    $ gem install psc

## Authentication

PSC supports two forms of authentication for API calls: HTTP Basic
(i.e., username & password) and psc_token. (Which forms are supported
in your PSC instance will depend on its authentication system
configuration.)

A particular client instance will only use one authentication
mechanism. There are three options.

### HTTP Basic

PSC Client allows you to specify a username and password to use for
all requests. Include the `:authenticator` key like so:

    :authenticator => { :basic => %w(alice password) }

    => Authorization: Basic YWxpY2U6cGFzc3dvcmQ=

### Static token

Alternatively, you can provide a token to use in all requests:

    :authenticator => { :token => 'The raven flies at midnight' }

    => Authorization: psc_token The raven flies at midnight

### Dynamic token

Finally, you can provide a callable object which will be invoked for
each request and whose return value will be used for the PSC token:

    :authenticator => { :token => lambda { cas_client.get_proxy_ticket } }

    => Authorization: psc_token PT-133-236H522

The callable will be called with no arguments.

## High-level interface

{Psc::Client} provides a high-level interface to some of PSC's API
capabilities.

## Low-level interface

`psc.rb` is based on [Faraday][], a modular ruby HTTP
client. {Psc::Connection} is a Faraday connection configured
for access to a particular PSC instance. You can create a
`Psc::Connection` directly:

    conn = Psc::Connection.new(
      'https://demos.nubic.northwestern.edu/psc',
      :authenticator => { :basic => %w(superuser superuser) })

Or you can get an instance from the {Psc::Client} high-level
interface:

    client = Psc::Client.new(
      'https://demos.nubic.northwestern.edu/psc',
      :authenticator => { :basic => %w(superuser superuser) })
    conn = client.connection

The connection is set up to automatically parse JSON reponses into
appropriate ruby primitives and XML responses into [Nokogiri][]
documents.

    studies_json = conn.get('studies.json')
    first_study_name =
      studies_json.body['studies'].first['assigned_identifier']

    sites_xml = conn.get('sites.xml')
    first_site_name =
      sites_xml.body.xpath('//psc:site', Psc.xml_namespace).first.attr('site-name')

Similarly, for PUT and POST it will encode a `Hash` or
`Array` entity as JSON and will assume that a `String` entity is XML.

[Faraday]: https://github.com/technoweenie/faraday
[Nokogiri]: http://nokogiri.org/

### URLs

PSC's API resources all start with `api/v1`. To help you DRY things
up, `PSC::Connection` automatically adds this to the base URL on
construction. You don't need to include it when constructing
relative URLs.

### Middleware

Faraday connections are built up from middleware. `Psc::Connection`
uses a combination of off-the-shelf and custom middleware classes. The
custom classes are in the {Psc::Faraday} module.

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
available in your PSC instance at `api/v1/docs`) before using this
library.

[psc]: https://code.bioinformatics.northwestern.edu/issues/wiki/psc

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

## High-level interface

`Psc::Client` provides a high-level interface to some of PSC's API
capabilities.

## Authentication

PSC supports two forms of authentication for API calls: HTTP Basic
(i.e., username & password) and token. (Which forms are supported in
your PSC instance will depend on its authentication system
configuration.)

A particular client instance will only use one authentication
mechanism. There are three options.

### HTTP Basic

PSC Client allows you to specify a username and password to use for
all requests. Include the `:authenticator` key like so:

    :authenticator => { :basic => [ 'alice', 'password ] }

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

## Low-level interface

`psc.rb` is based on [faraday][], a modular ruby HTTP
client. `Psc::Connection` gives you a faraday connection configured
for access to a particular PSC instance. For even more control, you
can look at the modules in `Psc::Faraday` for the middleware that
connection is built out of.

SSL in psc.rb
=============

psc.rb uses Faraday's `net/http` adapter by default. This adapter
verifies SSL certificates when used with HTTPS-served resources (as it
should). If the openssl install used by your ruby interpreter doesn't
have the CA certificate for your PSC instance, you'll get an exception
like this when you make a request:

`OpenSSL::SSL::SSLError: SSL_connect returned=1 errno=0 state=SSLv3 read server certificate B: certificate verify failed`

There are two ways to resolve this for psc.rb.

Configure OpenSSL with appropriate CA certificates
--------------------------------------------------

Depending on your OS & distribution, this may be as simple as
installing another package, or it might be fiendishly
complex/impossible. References:

* <http://gagravarr.org/writing/openssl-certs/others.shtml>
* <http://curl.haxx.se/ca/>

Configure PSC::Client or PSC::Connection
----------------------------------------

You can pass SSL options to the underlying adapter when creating a
{Psc::Client} or {Psc::Connection} instance:

    psc = Psc::Client.new(
      'https://demos.nubic.northwestern.edu/psc',
      :authenticator => { :basic => %w(superuser superuser) },
      :ssl => { :ca_file => '/etc/ssl/cacert.pem' }
    )

This example assumes you've put an appropriate CA certificate in
`/etc/ssl/cacert.pem`. (You can, of course, put it where ever you
like.) If you need a PEM-formatted version of the common commercial
certificates, <http://curl.haxx.se/ca/> is a good source.

This option is much easier to get working than the first one. It has
the downside that it requires that all platforms where you will run
your code have the CA certs in the same place or that you add a
another configuration option to your application.

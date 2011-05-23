# @title Integration Test PSC README

# Integration test PSC

This directory contains artifacts related to the PSC instance that
psc.rb deploys to run its integration tests. Highlights below.

## bin/

The integrated test infrastructure looks in this directory for a file
named `psc.war` to deploy. If you don't want to provide your own, you
can download the latest nightly by running `rake int-psc:war`.

This means you can run the integration tests against different
versions of PSC by swapping out `psc.war`.

## hsqldb/

The PSC instance is backed by HSQLDB. There are rake tasks to assist
in bootstrapping this database instance (which is mostly done via PSC
itself) in `tasks/int-psc.rake`. Process overview:

* Create a "baseline" configuration
* Deploy PSC against this configuration. PSC automatically creates its
  schema and lookup data.
* Interactively (i.e., this part is not scripted) walk through PSC's
  setup flow. Create a user named "superuser/superuser" that has all
  privileges.
* Shut down the "baseline" PSC. The HSQLDB database named "baseline"
  now contains the minimum set of data needed to deploy PSC and use
  its API.
* Copy the "baseline" database to a database named "datasource".
* Deploy PSC using the "datasource" database.
* Use PSC's dev demo-creator infrastructure to apply a consistent set
  of data (defined in `int-psc/state`) to this instance.
* Shut down the "datasource" instance of PSC.
* Mark the "datasource" database as read-only.

("baseline" and "datasource" are separate so that re-applying the
state data can be entirely scripted; baseline will (hopefully) never
need to be recreated.)

After this process is finished, each time you start up the integration
PSC instance it will be in the same state -- i.e., it will not persist
any data across restarts.

## state/

The desired contents of the integration test PSC instance on
startup. The key file is `int-psc-state.xml`, which is full of
comments describing its format.

Whenever you change the data this directory, you should run `rake
int-psc:rebuild` and then commit the changed versions of
`hsqldb/datasource.*` along with your data changes.

## deploy-base/logs/

The logs from the integration test PSC can be found here.

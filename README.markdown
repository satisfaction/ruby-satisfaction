Get Satisfaction Ruby library
=============================

Please check our Web site for the latest documentation:

[Web API documentation][1]

[Ruby library documentation][2]

For questions, please visit the [Get Satisfaction API community][3]

Changelog
=========
0.7.5

* Remove dependency on a specific version of active_support, now compatible with either rails 2.x or 3.x.

0.7.4

* Added the #slug attribute to the Sfn::Topic resource.

0.7.3

* Removed Net::Http patch to avoid SSL warning. (Note: This patch might cause other libraries that patch Net::Http to
  get into a funky state.)

0.7.1

* Integration smoke tests to validate proper ssl
request.
* Test loader code on the SSL context also
* Suppress the 'warning: peer certificate won't be verified in this SSL session'

0.7.0

* Revised Sfn::Resource so that it supports calls to API endpoints for nested resources
  (e.g. /companies/cid/products/pid/topics).

IMPORTANT NOTE: This version changes the gem behavior in a way that may introduce backwards incompatibility. In
particular, with prior versions, the following code:

      Satisfaction.new.companies['company_domain'].products['p_slug'].topics['t_slug'].tags

ignores the chained context of the final method call and simply sends a GET request to the following API endpoint:

      /topics/t_slug/tags

With this version, however, the gem will make API calls for nested resources in the API that correspond to the chained
method calls. In particular, the above code will instead attempt to send a GET request to the following endpoint:

      /companies/company_domain/products/p_slug/topics/t_slug/tags

In this particular case, the endpoint does not exist in the Get Satisfaction REST API, so API calls made to it will
yield a 404 Not Found response error.

0.6.7

* Fixed Sfn::Loader#get so it uses cached content when a 304 Not Modified is received.

0.6.6

* Handle HTTP 502/504 for unicorn.

0.6.5

* Fixed a divide-by-zero bug.

0.6.4

* Fixed a security issue with the resource associations and attributes.
* Provide a more descriptive error message when the client tries to access a community that has restricted its identity provider.

0.6.3

* Fixed known issue with scoping. Calling resource methods could potentially change scope for
  other objects. For example:

      sfn = Satisfaction.new
      sfn2 = Satisfaction.new
      person = sfn.peson.get('jargon')
      topics = sfn.topics.page(3, :order => 'recently_created') # Jargon's topics
      sfn2.topics # Also Jargon's topics

  This now behaves as expected (where topics and sfn2.topics would be scoped to the set of all i
  topics)

0.6.0

* The biggest change is that we're using exceptions to indicate error conditions. This will make it easier to detect errors, especially when chaining methods. We've also made it easier to tell when the site is in maintenance mode.
* Moved repository to https://github.com/satisfaction/ruby-satisfaction
* Updated gemspec to include all dependencies.
* Using Nokogiri instead of Hpricot
* Improved testing. Original tests ran against production. Our specs now use Fakeweb instead of trying to connect to a server. There still aren't very many specs, but changes in this release have coverage. 

[1]: http://getsatisfaction.com/developers/
[2]: http://getsatisfaction.com/developers/api-libraries
[3]: http://getsatisfaction.com/getsatisfaction/products/satisfaction_satisfaction_api

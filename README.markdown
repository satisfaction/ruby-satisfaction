Get Satisfaction Ruby library
=============================

Please check our Web site for the latest documentation:

[Web API documentation][1]

[Ruby library documentation][2]

For questions, please visit the [Get Satisfaction API community][3]

Changelog
=========

0.6.2

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

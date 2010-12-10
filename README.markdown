Get Satisfaction Ruby library
=============================

Please check our Web site for the latest documentation:

[Web API documentation][1]

[Ruby library documentation][2]

For questions, please visit the [Get Satisfaction API community][3]

Known Issues
============

If you use your Satisfaction object to get a person, then that object is scoped to that person.

For example:

  sfn = Satisfaction.new
  person = sfn.peson.get('jargon')
  topics = sfn.topics.page(3, :order => 'recently_created') # Jargon's topics

In the above case, topics will be scoped to topics created by Jargon instead of scoped to the
top level. A simple workaround for now is to create a new Satisfaction object like so:

  sfn = Satisfaction.new
  person = sfn.peson.get('jargon')

  sfn = Satisfaction.new
  topics = sfn.topics.page(3, :order => 'recently_created') # Everyone's topics

Changelog
=========

0.6.0

* The biggest change is that we're using exceptions to indicate error conditions. This will make it easier to detect errors, especially when chaining methods. We've also made it easier to tell when the site is in maintenance mode.
* Moved repository to https://github.com/satisfaction/ruby-satisfaction
* Updated gemspec to include all dependencies.
* Using Nokogiri instead of Hpricot
* Improved testing. Original tests ran against production. Our specs now use Fakeweb instead of trying to connect to a server. There still aren't very many specs, but changes in this release have coverage. 

[1]: http://getsatisfaction.com/developers/
[2]: http://getsatisfaction.com/developers/api-libraries
[3]: http://getsatisfaction.com/getsatisfaction/products/satisfaction_satisfaction_api

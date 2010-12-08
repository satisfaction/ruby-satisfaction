Changelog
=================================

0.6.0

* The biggest change is that we're using exceptions to indicate error conditions. This will make it easier to detect errors, especially when chaining methods. We've also made it easier to tell when the site is in maintenance mode.
* Moved repository to https://github.com/satisfaction/ruby-satisfaction
* Updated gemspec to include all dependencies.
* Using Nokogiri instead of Hpricot
* Improved testing. Original tests ran against production. Our specs now use Fakeweb instead of trying to connect to a server. There still aren't very many specs, but changes in this release have coverage. 

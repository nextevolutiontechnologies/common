LICENSE 
Copyright 2010-2011 Raymond Camden

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
   
If you find this application worthy, I have a Amazon wish list set up (www.amazon.com/o/registry/2TCL1D08EZEYE ). 

Last Updated: March 26, 2012 (0.9.3)
Bug in address verification service where entities of AddressKeyFormat may not exist.

Last Updated: May 19, 2011 (0.9.2)
NegotatedRates in rateservice.cfc now only shows up if you ask for it as an argument.

Last Updated: January 3, 2011 (0.9.1)
addressverficiation.cfc, rateservice.cfc, shipmenttracking.cfc, timeintransitservice.cfc - fixed missing var scopes - thanks to user Doug on RIAForge
rateservice.cfc - fix for when negotiatedrates didn't exist - also thanks to Doug.

Last Updated: September 2, 2010 (0.9)
Updated org/camden/ups/rateservice.cfc and servicecodes.xml
These updates are by Aaron Stoddard. I've used his email to me as a lazy way to handle the release notes:

So this has probably already been done but I wanted to let you know I was able to complete the Negotiated Rates Info part of your CFUPS component for UPS Package Ratings. It was actually pretty darn simple.

I am implementing your component in our intranet for our sales people to get sales quotes based on our negotiated rates with UPS. By passing in our shipper number (activated by our UPS rep with a discount) in the arguments, along with a small addition to the request XML, I was able to get the response to include the NegotiatedRates container with the discounted prices.

I added the following at the bottom of the request XML (but inside the <shipment> container):
<RateInformation>
<NegotiatedRatesIndicator></NegotiatedRatesIndicator>
</RateInformation>

By supplying UPS with this empty container, it tells the API to validate the shipper number and return the negotiated rates. The next step is simply adding the column to the query object you created and voila! Discounted rates! Note that the test server applies a discount of 1%.

Last Updated: July 27, 2010 (0.8)
Fixed an issue in addressverification.cfc where calls to street level and non-street level valdiation would cause the URLs to become screwed up.
In rateservice.cfc, you can now use a declared value for your packages.

Last Updated: July 16, 2010 (0.7)
Shane Pitts added street level validation. 

Last Updated: November 2, 2007 (0.6)
I had left in a test/abort in rateservice.cfc.

Last Updated: May 26, 2007 (0.5)
Bug fix to Time in Transit support.

Last Updated: May 26, 2007 (0.4)
Addition of Time in Transit support. Written by Kurt Bonnet. See timeintransmittest.cfm for an example.

Last Updated: January 14, 2007 (0.3)
Francisco Mancardi fixed a bug where the shipment tracking would throw an error when searching via
reference number.

Last Updated: January 5, 2007 (0.2)
Fixed a bug where a warning was being flagged as an error. These warnings are now shown
in the "responsewarning" column. There is only one unique value for this so if you need 
the value, just look at row 1. This is different from the warning column which applies
JUST to a particular service.

Last Updated: December 12, 2006 (0.1)
Initial release. No docs yet. Please note you MUST enable an application, get an XML key, and a username/password
before the test files will run. Docs will come soon.

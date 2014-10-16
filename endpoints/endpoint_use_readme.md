Endpoints available
=================================
This page provides a list of available endpoints available from Hack Oregon. These are currently served from an AWS instance using a combination of Postgresql and OpenResty.

To request additional endpoints or to report issues concerning those available please create a git hub issue here: https://github.com/hackoregon/backend/issues


Get total contributions from top 5 contributing individuals, for all recipients, in all of Oregon:
-------------------------------

Usage:

		http://54.213.83.132/hackoregon/http/oregon_individual_contributors/_/

Example output:

		[{"contributor_payee":"Loren Parks",
		 "sum":874300},
		 {"contributor_payee":"John Arnold",
		 "sum":500000},
		 {"contributor_payee":"Norman L Brenden",
		 "sum":495000},
		 {"contributor_payee":"Loren E Parks",
		 "sum":364173.58},
		 {"contributor_payee":"Philip Knight",
		 "sum":355000}]



Get total contributions from top 5 contributing businesses, for all recipients, in all of Oregon:
-------------------------------

Usage:

		http://54.213.83.132/hackoregon/http/oregon_committee_contributors/_/

Example output:

		[{"contributor_payee":"Future PAC, House Builders (1524)",
		 "sum":3554226.92},
		 {"contributor_payee":"Democratic Party of Oregon (353)",
		 "sum":1769467.27},
		 {"contributor_payee":"Citizen Action for Political Education (33)",
		 "sum":1652917.48},
		 {"contributor_payee":"Senate Democratic Leadership Fund (1471)",
		 "sum":1323317.99},
		 {"contributor_payee":"Promote Oregon Leadership PAC (682)",
		 "sum":1266427.24}]


Get all available data processing documentation
-------------------------------

Usage:

		http://54.213.83.132/hackoregon/http/all_documentation/_/

Example output:

		[{"title":"Summary of data for all of Oregon: contributions by individuals",
		 "endpoint_name":"oregon_individual_contributors",
		 "txt":"To compute contributions from individuals, transactions for the current campaign cycle are filtered to only those with the book type, Individual, and the sub types Cash Contribution and In-Kind Contribution. Then, for each unique contributor/payee all contribution amounts are added together."},
		 ...
		 }]


All oregon summary
---------------------------------

Gets summary statistics for all transactions in the current campaign cycle, for all of Oregon.

URL pattern: 

    http://54.213.83.132/hackoregon/http/all_oregon_sum/_/
    *note: this endpoint takes no argument, but the _ must be left in place. 

Example output:

    [{"in":212636760.45,
     "out":201910584.52,
     "from_within":56988212.71,
     "to_within":47640180.8399999,
     "from_outside":155648547.74,
     "to_outside":154270403.68,
     "total_grass_roots":10543857.78,
     "total_from_in_state":151870563.37}]

    in: money recieved by all sources
    out: money transfered from all sources
    from_within: money coming from entities within the political system.
    to_within: money transfered to entities within the political system. 
    from_outside: money coming from outside the political system. 
    to_outside: money going to entities outside the political system. 
    total_grass_roots: total money from grass roots donations (those less than $200)
    total_from_in_state: total donations coming from withing Oregon.  

Get transactions by day for all of Oregon
---------------------------------
Retreives several metrics describing transactions aggregated by day for all of Oregon. 
Data includes one row for each day in the current campaign cycle. 

URL pattern:

    http://54.213.83.132/hackoregon/http/state_sum_by_date/_/

Example output:

    [{"tran_date":"2010-11-12",
     "total_in":102880.69,
     "total_out":113078.47,
     "total_from_within":29485.08,
     "total_to_within":2447,
     "total_from_the_outside":73395.6099999999,
     "total_to_the_outside":110631.47,
     "total_grass_roots":3853.02,
     "total_from_in_state":45544.12},
    ...

Fields are as described above in the 'All oregon summary' endpoint. 


Get candidate/committee total in and total out by day
---------------------------------
Retreives total money in and total money out for every day of the current election cycle for a particular candiate. This is primarily for the time slider. 

The endpoint can be accessed using this URL pattern (in this example, we get data for Peter Courtney, who's committee id is 470):

    http://54.213.83.132/hackoregon/http/candidate_sum_by_date/470/
    
example output:

    [{"filer_id":470,
     "tran_date":"2010-11-16",
     "total_in":1000,
     "total_out":null},
     {"filer_id":470,
     "tran_date":"2010-11-19",
     "total_in":null,
     "total_out":18.86},
     ...
     truncated due to large number of records
     ...
     {"filer_id":470,
     "tran_date":"2014-10-03",
     "total_in":3500,
     "total_out":1050}]
     

get candidate money by state using committee IDs
---------------------------------
Two endpoints telling how much money a candidate (1) recieved from and (2) paid to each state in the US. (note Washington DC is translated to Maryland)

To get the money donated to a candidate from entities in each state (in this example, Peter Courtney, who's committee id is 470):
    
    http://54.213.83.132/hackoregon/http/candidate_in_by_state_by_id/470/


To get the money donated or paid by a candidate to entities in each state (in this example, Peter Courtney, who's committee id is 470):

    http://54.213.83.132/hackoregon/http/candidate_out_by_state_by_id/470/

Example output from finding money from a candidate (Peter Courtney) to various states:

        [{"state":"Maryland",
         "value":4175.85},
         {"state":"New Jersey",
         "value":288.55},
         {"state":"Oregon",
         "value":327198.64},
         {"state":"Washington",
         "value":117}]

---------------------------------
competitors from name or filer_id
---------------------------------

This endpoint will return all competitors in a race, given a candidate's name. If the given candidate is competing in more than one race, it will return all candidates competing in all the races inwhich the given candidate is competing. 

Note that this will also return information for the candidate whos name was given.

Example finding competitors for Bill Bradbury by name:

    http://54.213.83.132/hackoregon/http/competitors_from_name/Bill Bradbury/
    
Example finding competitors for Bill Bradbury by filer_id:

    http://54.213.83.132/hackoregon/http/competitors_from_filer_id/3571/

Example output:

    [{"candidate_name":"Bill Bradbury",
     "race":"Governor statewide",
     "website":"www.bradbury2010.com",
     "phone":null,
     "total":8032.88,
     "grassroots":0,
     "instate":1,
     "committee_names":"Friends of Bill Bradbury",
     "filer_id":3571},
     {"candidate_name":"Ron Saxton",
     "race":"Governor statewide",
     "website":null,
     "phone":"(503)478-4463",
     "total":1.81,
     "grassroots":1,
     "instate":0,
     "committee_names":"Friends of Ron Saxton",
     "filer_id":3503}]



---------------------------------
candidate search
---------------------------------
Fuzzy string match to get candidate data by entering their approximate name.

  Usage:
    Entering the search string "bil brad" using this URL pattern
    
          http://54.213.83.132/hackoregon/http/candidate_search/bil brad/
          
    will perform fuzzy matching with candidate names and will return a JSON document describing basic data for Bill Bradbury.
  Example of returned JSON:
  
          [{"candidate_name":"Bill Bradbury",
          "race":"Governor statewide",
          "website":"www.bradbury2010.com",
          "phone":null,
          "total":8032.88,
          "grassroots":0,
          "instate":1,
          "committee_names":"Friends of Bill Bradbury",
          "filer_id":3571}]
---------------------------------
committee map
---------------------------------
Get mapping between commitee id to committee name to candidate name for all candidates in the current election cycle.
    
    Usage:
    
        http://54.213.83.132/hackoregon/http/committee_map/blnk/
      
    The argument "blnk" doesn't actually do anything but must be there
---------------------------------  
top committee data
---------------------------------
Get data for the top n committees, ordered by total money raised in the current campaign cycle (everything since 2010-11-11). 

  Usage:
  
        http://54.213.83.132/hackoregon/http/top_committee_data/3/
    
  Will return data for the top 3 committees. 
  
  Example of returned JSON:

        [{"candidate_name":"Brad Avakian",
         "race":"Commissioner of the Bureau of Labor and Industries statewide",
         "website":null,
         "phone":"(503)970-9296",
         "total":279975.26,
         "grassroots":0.0807254898164931,
         "instate":0.890564080554832,
         "committee_names":"Committee to Elect Brad Avakian",
         "filer_id":4152}]
--------------------------------- 
committee data by id
---------------------------------
Get data for a particular candidate committee, using the candidate's committee ID

  Usage:
    
    http://54.213.83.132/hackoregon/http/committee_data_by_id/470/
    
  Will return this JSON, giving information for Peter Courtney:
  
      [{"candidate_name":"Peter Courtney",
     "committee_name":"Peter Courtney for State Senate",
     "race":"2014 Primary Election State Senator 11th District",
     "website":"votepetercourtney.com",
     "phone":"wk:(503)986-1600 hm: fx:",
     "total":485302.58,
     "grassroots":0.00409775278754957,
     "instate":0.84772386744781,
     "filer_id":470}]
--------------------------------- 
current transactions
---------------------------------
Get transaction data for a particular candidate for the current campaign cycle (everything since 2010-11-11).

  Usage:
    
    http://54.213.83.132/hackoregon/http/current_transactions/4792/
  
  This will return a JSON with all transactions for the current campaign cycle for the committee with committee id 4792 (That of Tina Kotek)
  

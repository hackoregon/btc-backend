Endpoints available:

---------------------------------
get candidate money by state
---------------------------------
Two endpoints telling how much money a candidate (1) gave and (2) recieved from each state in the US. (note Washington DC is translated to Maryland)

To get the money donated to a candidate from entities in each state (in this example, Brad Avakian):
    
    http://54.213.83.132/hackoregon/http/candidate_in_by_state/Brad Avakian/


To get the money donated or paid by a candidate to entities in each state (in this example, Brad Avakian):

    http://54.213.83.132/hackoregon/http/candidate_out_by_state/Brad Avakian/

Example output:
    [{"state":"Arkansas",
     "value":100},
     {"state":"California",
     "value":3282.69},
     {"state":"Maryland",
     "value":38333.12},
     {"state":"Idaho",
     "value":150},
     {"state":"Maryland",
     "value":12600},
     {"state":"New Mexico",
     "value":2500},
     {"state":"Nevada",
     "value":5000},
     {"state":"New York",
     "value":500},
     {"state":"Ohio",
     "value":1000},
     {"state":"Oregon",
     "value":960617.24},
     {"state":"Pennsylvania",
     "value":500},
     {"state":"Washington",
     "value":39400}]

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
committee data
---------------------------------
Get data for a particular candidate committee, using the candidate's name

  Usage:
    
    http://54.213.83.132/hackoregon/http/committee_data/Tina Kotek/
    
  Will return this JSON, giving information for Tina Kotek:
  
      [{"candidate_name":"Tina Kotek",
       "race":"State Representative 44th District",
       "website":"",
       "phone":"(503)449-9767",
       "total":212932.19,
       "grassroots":0.00503446660648162,
       "instate":0.717790673171586,
       "committee_names":"Friends of Tina Kotek",
       "filer_id":4792}]
--------------------------------- 
current transactions
---------------------------------
Get transaction data for a particular candidate for the current campaign cycle (everything since 2010-11-11).

  Usage:
    
    http://54.213.83.132/hackoregon/http/current_transactions/4792/
  
  This will return a JSON with all transactions for the current campaign cycle for the committee with committee id 4792 (That of Tina Kotek)
  

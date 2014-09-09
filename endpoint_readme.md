Endpoints available:
---------------------------------
candidate search: Fuzzy string match to get candidate data by entering their approximate name.
  
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
committee map: get mapping between commitee id to committee name to candidate name for all candidates in the current election cycle.
    
    Usage:
    
        http://54.213.83.132/hackoregon/http/committee_map/blnk/
      
    The argument "blnk" doesn't actually do anything but must be there
---------------------------------  
top committee data: get data for the top n committees, ordered by total money raised. 

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
committee data: get data for a particular candidate committee, using the candidate's name

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
current transactions: get transaction data for a particular candidate for the current campaign cycle

  Usage:
    
    http://54.213.83.132/hackoregon/http/current_transactions/4792/
  
  This will return a JSON with all transactions for the current campaign cycle for the committee with committee id 4792 (That of Tina Kotek)
  

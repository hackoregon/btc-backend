curl -s -c cookies -o /dev/null "https://secure.sos.state.or.us/orestar/GotoSearchByElection.do"

curl -s -b cookies -o /dev/null --data "yearActive=2010&discontinuedSOO=on&buttonName=electionSearch" https://secure.sos.state.or.us/orestar/CommitteeSearchSecondPage.do

curl -s -b cookies https://secure.sos.state.or.us/orestar/XcelSooSearch > 2010.xls
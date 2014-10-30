var request = require('request'),
	cookieJar = request.jar(),
	async = require('async'),
	fs = require('fs'),
	moment = require('moment'),
	argv = require('minimist')(process.argv.slice(2)),
    startDate = moment(argv['_'][0]).format('MM/DD/YYYY'),
    minimumDate = moment(argv['_'][1]).format('MM/DD/YYYY'),
    delay = (argv['_'][2] || 10) * 1000;

	request = request.defaults({jar: cookieJar});

var searchUrl = 'https://secure.sos.state.or.us/orestar/gotoPublicTransactionSearchResults.do?cneSearchButtonName=newSearch&cneSearchPageIdx=0&sort=desc&by=FILED_DATE',
	postUrl = 'https://secure.sos.state.or.us/orestar/gotoPublicTransactionSearchResults.do',
	exportUrl = 'https://secure.sos.state.or.us/orestar/XcelCNESearch';
	

	var dates = [];
	var cont = true,
		dateRange,
		nextDate = startDate;


	while(cont) {
		dateRange = getDateRange(nextDate, minimumDate);
		dates.push(dateRange);

		cont = dateRange.end != minimumDate

		nextDate = moment(dateRange.end).subtract('days', 1);

	}

	function getDateRange(startDate, minimum) {
		var startFormatted = moment(startDate).format('MM/DD/YYYY');
		var endDate = moment(startDate).subtract('days', 7).valueOf();
		var minimumDate = moment(minimum).valueOf();
		var endDateFormatted;

		if (minimumDate > endDate || minimumDate == endDate) {
			endDateFormatted = moment(minimumDate).format('MM/DD/YYYY');
		} else if (endDate > minimumDate) {
			endDateFormatted = moment(endDate).format('MM/DD/YYYY');
		}

		return {
			start: startFormatted,
			end: endDateFormatted
		}
	}



 async.eachSeries(dates, function(dateRange, completeCb) {


 	var searchOptions = getSearchOptions(dateRange.start, dateRange.end);

	request.get(postUrl + '?' + searchOptions, { 
		headers: {
			'Referer': searchUrl,
			'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1985.125 Safari/537.36'
		}
	}, function(err, resp, body) {
		var stream = fs.createWriteStream('./' + dateRange.start.split('/').join('-') + '_' + dateRange.end.split('/').join('-') + '.xls');
		request(exportUrl).pipe(stream);
		setTimeout(function() {
			completeCb(null, true);
		}, delay)
	})


 })


function getSearchOptions(to, from) {

	return 'cneSearchButtonName=search&cneSearchPageIdx=&cneSearchContributorTypeName=&cneSearchTranTypeName=&cneSearchTranSubTypeName=&cneSearchTranPurposeName=&cneSearchFilerCommitteeId=&cneSearchFilerCommitteeTxt=&cneSearchFilerCommitteeTxtSearchType=C&cneSearchTranStartDate=&cneSearchTranEndDate=&cneSearchTranFiledStartDate=' + from + '&cneSearchTranFiledEndDate=' + to + '&transactionId=&cneSearchTranType=&cneSearchTranAmountFrom=&cneSearchTranAmountTo=&cneSearchContributorTxt=&cneSearchContributorTxtSearchType=C&cneSearchContributorType=&addressLine1=&city=&state=&zip=&zipPlusFour=&occupation=&employer=&employerCity=&employerState=';
}


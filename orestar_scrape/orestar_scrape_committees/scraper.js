var request = require('request'),
	cheerio = require('cheerio'),
	cookieJar = request.jar(),
	argv = require('minimist')(process.argv.slice(2));

	request = request.defaults({jar: cookieJar});
	
var searchUrl = 'https://secure.sos.state.or.us/orestar/GotoSearchByName.do',
	postUrl = 'https://secure.sos.state.or.us/orestar/CommitteeSearchFirstPage.do',
	searchOptions = {
		buttonName: '',
		page:1,
		committeeName:'',
		committeeNameMultiboxText:'contains',
		committeeId:argv['_'][0],
		firstName:'',
		firstNameMultiboxText:'contains',
		lastName:'',
		lastNameMultiboxText:'contains',
		submit:'Submit',
		discontinuedSOO:'false',
		approvedSOO:'true',
		pendingApprovalSOO:'false',
		insufficientSOO:'false',
		resolvedSOO:'false',
		rejectedSOO:'false'
	};

var tableNames = ['Committee Information',
					'Treasurer Information',
					'Candidate Information'
					];


var idInfo = {};
	request(searchUrl, function() {
		
		request.post(postUrl,{form: searchOptions}, function(err, resp, body) {
			var $ = cheerio.load(body),
				table;

			tableNames.forEach(function(name) {
				table = $('h5:contains(' + name + ')').eq(0).closest('table');
				idInfo[name] = {};

				table.find('td.label').each(function() {
					var label = $(this).text();
					var value = $(this).next().text();
					idInfo[name][label] = value;
				});
			});

			console.log(idInfo);
		})
	});



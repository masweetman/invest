var fs = require('fs');
var casper = require('casper').create();
var url = 'http://financials.morningstar.com/ratios/r.html?t=';

ticker = casper.cli.get(0);
railsroot = casper.cli.get(1);

casper.start().then(function() {
    this.open(url + ticker, {
        method: 'get',
        headers: {
            'Accept': 'application/json'
        }
    });
});

casper.run(function() {
    filename = ticker + '.html';
    filepath = railsroot + '/data/'
    filepath = fs.pathJoin(filepath, filename);
    fs.write(filepath, this.getPageContent(), 'w');
    this.exit();
});
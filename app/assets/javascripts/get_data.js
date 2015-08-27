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
    casper.echo(this.getPageContent());
    this.exit();
});
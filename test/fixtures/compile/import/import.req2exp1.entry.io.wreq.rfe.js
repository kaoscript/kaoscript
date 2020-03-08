require("kaoscript/register");
module.exports = function(Foobar) {
	var Foobar = require("./import.req2exp1.pivot.ks")(Foobar).Foobar;
	const f = new Foobar();
	console.log(f.x());
};
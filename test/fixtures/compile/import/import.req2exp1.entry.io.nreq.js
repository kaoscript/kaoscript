require("kaoscript/register");
module.exports = function() {
	var Foobar = require("./import.req2exp1.pivot.ks")().Foobar;
	const f = new Foobar();
	console.log(f.x());
};
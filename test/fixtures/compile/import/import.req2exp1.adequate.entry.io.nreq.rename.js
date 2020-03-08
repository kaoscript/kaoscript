require("kaoscript/register");
module.exports = function() {
	var {Foobar, Quxbaz: Corge} = require("./import.req2exp1.adequate.pivot.ks")();
	const f = new Foobar();
	console.log(f.x());
};
require("kaoscript/register");
module.exports = function(Foobar, Quxbaz) {
	var {Foobar, Quxbaz} = require("./import.req2exp1.adequate.pivot.ks")(Foobar, Quxbaz);
	const f = new Foobar();
	console.log(f.x());
};
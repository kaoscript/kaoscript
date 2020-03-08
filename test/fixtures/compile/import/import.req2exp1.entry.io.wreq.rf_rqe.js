require("kaoscript/register");
module.exports = function(Foobar, Quxbaz) {
	var Foobar = require("./import.req2exp1.pivot.ks")(Foobar, Quxbaz).Foobar;
	const f = new Foobar();
	console.log(f.x());
};
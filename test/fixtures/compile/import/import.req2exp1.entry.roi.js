require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(Foobar) {
	if(!Type.isValue(Foobar)) {
		var Foobar = require("./import.req2exp1.pivot.ks")().Foobar;
	}
	const f = new Foobar();
	console.log(f.x());
};
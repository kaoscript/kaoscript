require("kaoscript/register");
module.exports = function() {
	var foobar = require("./type.nulltype.param.union.default.ks")().foobar;
	foobar(42);
	foobar("White");
	foobar(null);
};
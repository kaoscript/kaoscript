require("kaoscript/register");
module.exports = function() {
	var Foobar = require("./dictionary.export.generics.struct.sl.ks")().Foobar;
	return {
		Foobar: Foobar
	};
};
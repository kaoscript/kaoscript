require("kaoscript/register");
module.exports = function() {
	var Foobar = require("./dictionary.export.generics.struct.dl.ks")().Foobar;
	return {
		Foobar: Foobar
	};
};
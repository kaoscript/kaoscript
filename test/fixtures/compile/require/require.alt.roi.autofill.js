require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(Color) {
	class Color {
		constructor() {
			this.__ks_init();
			this.__ks_cons(arguments);
		}
		__ks_init() {
		}
		__ks_cons(args) {
			if(args.length !== 0) {
				throw new SyntaxError("Wrong number of arguments");
			}
		}
	}
	if(!Type.isValue(Color)) {
		var Color = require("./require.default.ks")(Color).Color;
	}
};
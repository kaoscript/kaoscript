var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
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
	Color.registerSpace({
		"name": "FBQ",
		"formatters": {
			srgb(that) {
				if(arguments.length < 1) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(that === void 0 || that === null) {
					throw new TypeError("'that' is not nullable");
				}
				else if(!Type.is(that, Color)) {
					throw new TypeError("'that' is not of type 'Color'");
				}
				if(that._foo) {
				}
				else if(that._bar) {
				}
			}
		}
	});
	return {
		Color: Color
	};
};
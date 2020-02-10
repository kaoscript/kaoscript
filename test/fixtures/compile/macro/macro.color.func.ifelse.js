var {Dictionary, Type} = require("@kaoscript/runtime");
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
	Color.registerSpace((() => {
		const d = new Dictionary();
		d["name"] = "FBQ";
		d["formatters"] = (() => {
			const d = new Dictionary();
			d.srgb = function(that) {
				if(arguments.length < 1) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
				}
				if(that === void 0 || that === null) {
					throw new TypeError("'that' is not nullable");
				}
				else if(!Type.isClassInstance(that, Color)) {
					throw new TypeError("'that' is not of type 'Color'");
				}
				if(that._foo === true) {
				}
				else if(that._bar === true) {
				}
				return "";
			};
			return d;
		})();
		return d;
	})());
	return {
		Color: Color
	};
};
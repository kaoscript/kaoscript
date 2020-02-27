var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let Color = Helper.enum(Number, {
		Red: 0,
		Green: 1,
		Blue: 2
	});
	function foobar() {
		if(arguments.length === 1 && Type.isEnumInstance(arguments[0], Color)) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isEnumInstance(x, Color)) {
				throw new TypeError("'x' is not of type 'Color'");
			}
			return 0;
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			return 1;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};
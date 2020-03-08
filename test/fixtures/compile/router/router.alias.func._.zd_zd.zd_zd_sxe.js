var Type = require("@kaoscript/runtime").Type;
module.exports = function() {
	function foobar() {
		if(arguments.length === 0) {
			return 0;
		}
		else if((arguments.length === 1 && Type.isRegExp(arguments[0])) || (arguments.length === 2 && Type.isRegExp(arguments[1])) || arguments.length === 3) {
			let __ks_i = -1;
			let x;
			if(arguments.length > __ks_i + 2 && (x = arguments[++__ks_i]) !== void 0 && x !== null) {
				if(!Type.isNumber(x) && !Type.isString(x)) {
					if(arguments.length - __ks_i < 3) {
						x = 0;
						--__ks_i;
					}
					else {
						throw new TypeError("'x' is not of type 'NS'");
					}
				}
			}
			else {
				x = 0;
			}
			let y;
			if(arguments.length > __ks_i + 2 && (y = arguments[++__ks_i]) !== void 0 && y !== null) {
				if(!Type.isNumber(y) && !Type.isString(y)) {
					if(arguments.length - __ks_i < 2) {
						y = 0;
						--__ks_i;
					}
					else {
						throw new TypeError("'y' is not of type 'NS'");
					}
				}
			}
			else {
				y = 0;
			}
			let z = arguments[++__ks_i];
			if(z === void 0 || z === null) {
				throw new TypeError("'z' is not nullable");
			}
			else if(!Type.isString(z) && !Type.isRegExp(z)) {
				throw new TypeError("'z' is not of type 'String' or 'RegExp'");
			}
			return 2;
		}
		else if(arguments.length === 1 || arguments.length === 2) {
			let __ks_i = -1;
			let x;
			if(arguments.length > ++__ks_i && (x = arguments[__ks_i]) !== void 0 && x !== null) {
				if(!Type.isNumber(x) && !Type.isString(x)) {
					if(arguments.length - __ks_i < 2) {
						x = 0;
						--__ks_i;
					}
					else {
						throw new TypeError("'x' is not of type 'NS'");
					}
				}
			}
			else {
				x = 0;
			}
			let y;
			if(arguments.length > ++__ks_i && (y = arguments[__ks_i]) !== void 0 && y !== null) {
				if(!Type.isNumber(y) && !Type.isString(y)) {
					throw new TypeError("'y' is not of type 'NS'");
				}
			}
			else {
				y = 0;
			}
			return 1;
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
};
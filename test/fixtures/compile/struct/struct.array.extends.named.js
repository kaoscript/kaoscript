var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Pair = Helper.struct(function() {
		let __ks_i = -1;
		let x;
		if(arguments.length > ++__ks_i && (x = arguments[__ks_i]) !== void 0 && x !== null) {
			if(!Type.isString(x)) {
				if(arguments.length - __ks_i < 2) {
					x = "";
					--__ks_i;
				}
				else {
					throw new TypeError("'x' is not of type 'String'");
				}
			}
		}
		else {
			x = "";
		}
		let y;
		if(arguments.length > ++__ks_i && (y = arguments[__ks_i]) !== void 0 && y !== null) {
			if(!Type.isNumber(y)) {
				throw new TypeError("'y' is not of type 'Number'");
			}
		}
		else {
			y = 0;
		}
		return [x, y];
	});
	var Triple = Helper.struct(function(x, y, z) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(z === void 0 || z === null) {
			z = false;
		}
		else if(!Type.isBoolean(z)) {
			throw new TypeError("'z' is not of type 'Boolean'");
		}
		const _ = Pair.__ks_builder(__ks_0, __ks_1);
		_.push(__ks_2);
		return _;
	}, Pair);
	const triple = Triple("x", 0.1, true);
	console.log(triple[0], triple[1] + 1, !triple[2]);
	return {
		Pair: Pair,
		Triple: Triple
	};
};
var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Pair = Helper.tuple(function(__ks_0, __ks_1) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(__ks_0 === void 0 || __ks_0 === null) {
			throw new TypeError("'__ks_0' is not nullable");
		}
		else if(!Type.isString(__ks_0)) {
			throw new TypeError("'__ks_0' is not of type 'String'");
		}
		if(__ks_1 === void 0 || __ks_1 === null) {
			throw new TypeError("'__ks_1' is not nullable");
		}
		else if(!Type.isNumber(__ks_1)) {
			throw new TypeError("'__ks_1' is not of type 'Number'");
		}
		return [__ks_0, __ks_1];
	});
	var Triple = Helper.tuple(function(__ks_0, __ks_1, __ks_2) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(__ks_2 === void 0 || __ks_2 === null) {
			throw new TypeError("'__ks_2' is not nullable");
		}
		else if(!Type.isBoolean(__ks_2)) {
			throw new TypeError("'__ks_2' is not of type 'Boolean'");
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
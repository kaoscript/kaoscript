var {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var Pair = Helper.struct(function(__ks_0, __ks_1) {
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
	function foobar(__ks_struct_1) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(__ks_struct_1 === void 0 || __ks_struct_1 === null) {
			throw new TypeError("'struct' is not nullable");
		}
		else if(!Type.isStruct(__ks_struct_1)) {
			throw new TypeError("'struct' is not of type 'Struct'");
		}
	}
	foobar(Pair);
};
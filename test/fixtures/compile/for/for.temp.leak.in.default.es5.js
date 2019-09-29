var Helper = require("@kaoscript/runtime").Helper;
module.exports = function() {
	function init(data, builder) {
		if(arguments.length < 2) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
		}
		if(data === void 0 || data === null) {
			throw new TypeError("'data' is not nullable");
		}
		if(builder === void 0 || builder === null) {
			throw new TypeError("'builder' is not nullable");
		}
		var block = builder.newBlock();
		for(var __ks_0 = 0, __ks_1 = data.block(data.body).statements, __ks_2 = __ks_1.length, statement; __ks_0 < __ks_2; ++__ks_0) {
			statement = __ks_1[__ks_0];
			block.statement(statement);
		}
		block.done();
		var source = "";
		for(var __ks_0 = 0, __ks_1 = builder.toArray(), __ks_2 = __ks_1.length, fragment; __ks_0 < __ks_2; ++__ks_0) {
			fragment = __ks_1[__ks_0];
			source = Helper.concatString(source, fragment.code);
		}
		return source;
	}
};
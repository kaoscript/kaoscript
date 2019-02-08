require("kaoscript/register");
module.exports = function() {
	var reverse = require("../function/function.overloading.export.ks")().reverse;
	var reverse = require("../require/require.func.default.ks")(reverse).reverse;
	return {
		reverse: reverse
	};
};
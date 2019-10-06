var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foobar(__ks_sealed_1) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(__ks_sealed_1 === void 0 || __ks_sealed_1 === null) {
			throw new TypeError("'sealed' is not nullable");
		}
		return (function() {
			var d = new Dictionary();
			d.sealed = __ks_sealed_1;
			return d;
		})();
	}
};
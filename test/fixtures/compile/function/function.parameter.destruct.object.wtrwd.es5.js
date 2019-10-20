var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	function foobar(__ks_0) {
		if(__ks_0 === void 0 || __ks_0 === null) {
			__ks_0 = (function() {
				var d = new Dictionary();
				d.x = "foo";
				d.y = "bar";
				return d;
			})();
		}
		var x = __ks_0.x, y = __ks_0.y;
		console.log(x + "." + y);
	}
};
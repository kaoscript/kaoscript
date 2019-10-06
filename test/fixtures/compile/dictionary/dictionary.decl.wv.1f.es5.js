var __ks__ = require("@kaoscript/runtime");
var Dictionary = __ks__.Dictionary, Type = __ks__.Type;
module.exports = function() {
	var foo = (function() {
		var d = new Dictionary();
		d.bar = function(name) {
			if(name === void 0) {
				name = null;
			}
			else if(name !== null && !Type.isString(name)) {
				throw new TypeError("'name' is not of type 'String?'");
			}
			var n = 0;
		};
		return d;
	})();
};
var {Dictionary, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_size_0 = function(item) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(item === void 0 || item === null) {
			throw new TypeError("'item' is not nullable");
		}
		else if(!Type.isDictionary(item)) {
			throw new TypeError("'item' is not of type 'Dictionary'");
		}
		return 0;
	};
	__ks_Dictionary._cm_size = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 1) {
			return __ks_Dictionary.__ks_sttc_size_0.apply(null, args);
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	console.log(__ks_Dictionary._cm_size((() => {
		const d = new Dictionary();
		d.name = "White";
		d.honorific = "miss";
		return d;
	})()));
};
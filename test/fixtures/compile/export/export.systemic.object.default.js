var Dictionary = require("@kaoscript/runtime").Dictionary;
module.exports = function() {
	var __ks_Dictionary = {};
	__ks_Dictionary.__ks_sttc_clone_0 = function() {
		return this;
	};
	__ks_Dictionary._cm_clone = function() {
		var args = Array.prototype.slice.call(arguments);
		if(args.length === 0) {
			return __ks_Dictionary.__ks_sttc_clone_0();
		}
		throw new SyntaxError("Wrong number of arguments");
	};
	const foobar = (() => {
		const d = new Dictionary();
		d.qux = 42;
		return d;
	})();
	return {
		foobar: foobar
	};
};
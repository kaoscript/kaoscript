const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(a, b) {
		if(a === void 0) {
			a = null;
		}
		if(b === void 0) {
			b = null;
		}
		if(Type.isString(a) && Type.isString(b)) {
			return a.toLowerCase() === b.toLowerCase();
		}
		else {
			return false;
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 2) {
			return foobar.__ks_0.call(that, args[0], args[1]);
		}
		throw Helper.badArgs();
	};
};
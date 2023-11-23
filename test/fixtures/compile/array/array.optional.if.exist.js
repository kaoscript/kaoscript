const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function pair() {
		return pair.__ks_rt(this, arguments);
	};
	pair.__ks_0 = function(x, y) {
		if(x === void 0) {
			x = null;
		}
		if(y === void 0) {
			y = null;
		}
		return (() => {
			const a = [];
			if(Type.isValue(x)) {
				a[0] = x.value;
			}
			if(Type.isValue(y)) {
				a.push(y.value);
			}
			return a;
		})();
	};
	pair.__ks_rt = function(that, args) {
		if(args.length === 2) {
			return pair.__ks_0.call(that, args[0], args[1]);
		}
		throw Helper.badArgs();
	};
};
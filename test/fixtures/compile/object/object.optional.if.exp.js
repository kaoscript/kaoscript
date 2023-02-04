const {Helper, OBJ, Type} = require("@kaoscript/runtime");
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
			const o = new OBJ();
			if(Type.isValue(x)) {
				o.x = x.value;
			}
			if(Type.isValue(y)) {
				o.y = y.value;
			}
			return o;
		})();
	};
	pair.__ks_rt = function(that, args) {
		if(args.length === 2) {
			return pair.__ks_0.call(that, args[0], args[1]);
		}
		throw Helper.badArgs();
	};
};
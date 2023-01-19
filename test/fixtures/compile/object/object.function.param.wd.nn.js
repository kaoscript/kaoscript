const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		if(x === void 0 || x === null) {
			x = (() => {
				const o = new OBJ();
				o.y = 42;
				return o;
			})();
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};
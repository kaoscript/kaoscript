const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		if(x === void 0) {
			x = null;
		}
		if(y === void 0) {
			y = null;
		}
		if((x === true) !== (y === true)) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 2) {
			return foobar.__ks_0.call(that, args[0], args[1]);
		}
		throw Helper.badArgs();
	};
};
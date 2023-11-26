const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, 0, "Red", 0, "Green", 1, "Blue", 2);
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(color) {
		if(color === void 0) {
			color = null;
		}
		if(Helper.valueOf(color) === Color.Red.value) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};
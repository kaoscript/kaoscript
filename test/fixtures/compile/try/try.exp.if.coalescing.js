const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function test() {
		return test.__ks_rt(this, arguments);
	};
	test.__ks_0 = function(x) {
		if(x === true) {
			return true;
		}
		else {
			throw new Error("foobar");
		}
	};
	test.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return test.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	if(Helper.try(() => test.__ks_0(true), false)) {
	}
	else {
	}
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		let __ks_0;
		__ks_0 = values.length();
		Helper.assertLoop(1, "values.length()", __ks_0, "", 0, 0, "", 0);
		for(let i = __ks_0 - 1; i >= 0; --i) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
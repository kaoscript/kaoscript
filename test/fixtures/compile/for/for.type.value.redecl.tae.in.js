const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values) {
		let value;
		for(let __ks_1 = 0, __ks_0 = values.length; __ks_1 < __ks_0; ++__ks_1) {
			value = values[__ks_1];
			console.log(value);
		}
		console.log(Helper.toString(value));
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
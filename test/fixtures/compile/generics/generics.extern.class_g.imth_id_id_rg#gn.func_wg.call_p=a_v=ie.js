const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(values, index) {
		const deleteds = values.splice({T: Type.any}, index, 10);
		for(let __ks_1 = 0, __ks_0 = deleteds.length, del; __ks_1 < __ks_0; ++__ks_1) {
			del = deleteds[__ks_1];
			console.log(Helper.toString(del));
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isClassInstance(value, Stack);
		const t1 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};
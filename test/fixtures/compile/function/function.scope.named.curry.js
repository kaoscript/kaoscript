const {Helper, Operator, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function test() {
		return test.__ks_rt(this, arguments);
	};
	test.__ks_0 = function(__ks_case_1, year, index) {
		const d = new Date(year, __ks_case_1[0], __ks_case_1[1]);
		expect(d.getDay()).to.equal(__ks_case_1[Operator.add(index, 2)]);
	};
	test.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t0(args[2])) {
				return test.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	const functions = [];
	const cases = [[1, 1, 6, 2], [6, 15, 3, 6], [12, 3, 0, 3]];
	for(let __ks_0 = 0, __ks_1 = cases.length, __ks_case_1; __ks_0 < __ks_1; ++__ks_0) {
		__ks_case_1 = cases[__ks_0];
		for(let i = 0, __ks_2 = [1992, 2000], __ks_3 = __ks_2.length, year; i < __ks_3; ++i) {
			year = __ks_2[i];
			functions.push(Helper.vcurry(test, null, __ks_case_1, year, i));
		}
	}
	for(let __ks_0 = 0, __ks_1 = functions.length, fn; __ks_0 < __ks_1; ++__ks_0) {
		fn = functions[__ks_0];
		fn();
	}
};
var Helper = require("@kaoscript/runtime").Helper;
module.exports = function(expect) {
	function test() {
		var __ks_000 = function(year, __ks_case_1, i) {
			var d = new Date(year, __ks_case_1[0], __ks_case_1[1]);
			expect(d.getDay()).to.equal(__ks_case_1[i + 2]);
		}
		var functions = [];
		var cases = [[1, 1, 6, 2], [6, 15, 3, 6], [12, 3, 0, 3]];
		for(var __ks_0 = 0, __ks_1 = cases.length, __ks_case_1; __ks_0 < __ks_1; ++__ks_0) {
			__ks_case_1 = cases[__ks_0];
			for(var i = 0, __ks_2 = [1992, 2000], __ks_3 = __ks_2.length, year; i < __ks_3; ++i) {
				year = __ks_2[i];
				functions.push(Helper.vcurry(__ks_000, null, year, __ks_case_1, i));
			}
		}
		for(var __ks_0 = 0, __ks_1 = functions.length, fn; __ks_0 < __ks_1; ++__ks_0) {
			fn = functions[__ks_0];
			fn();
		}
	}
};
var {Helper, Operator} = require("@kaoscript/runtime");
module.exports = function(expect) {
	function test(__ks_case_1, year, index) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(__ks_case_1 === void 0 || __ks_case_1 === null) {
			throw new TypeError("'case' is not nullable");
		}
		if(year === void 0 || year === null) {
			throw new TypeError("'year' is not nullable");
		}
		if(index === void 0 || index === null) {
			throw new TypeError("'index' is not nullable");
		}
		const d = new Date(year, __ks_case_1[0], __ks_case_1[1]);
		expect(d.getDay()).to.equal(__ks_case_1[Operator.addOrConcat(index, 2)]);
	}
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
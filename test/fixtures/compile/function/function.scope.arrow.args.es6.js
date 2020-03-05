var Operator = require("@kaoscript/runtime").Operator;
module.exports = function(expect) {
	const functions = [];
	const cases = [[1, 1, 6, 2], [6, 15, 3, 6], [12, 3, 0, 3]];
	for(let __ks_0 = 0, __ks_1 = cases.length, __ks_case_1; __ks_0 < __ks_1; ++__ks_0) {
		__ks_case_1 = cases[__ks_0];
		for(let i = 0, __ks_2 = [1992, 2000], __ks_3 = __ks_2.length, year; i < __ks_3; ++i) {
			year = __ks_2[i];
			functions.push(function(x, y) {
				if(arguments.length < 2) {
					throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 2)");
				}
				if(x === void 0 || x === null) {
					throw new TypeError("'x' is not nullable");
				}
				if(y === void 0 || y === null) {
					throw new TypeError("'y' is not nullable");
				}
				const d = new Date(year, __ks_case_1[0], __ks_case_1[1]);
				expect(d.getDay()).to.equal(Operator.addOrConcat(__ks_case_1[i + 2], x));
			});
		}
	}
	for(let __ks_0 = 0, __ks_1 = functions.length, fn; __ks_0 < __ks_1; ++__ks_0) {
		fn = functions[__ks_0];
		fn(1, 2);
	}
};
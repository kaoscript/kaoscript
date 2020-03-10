require("kaoscript/register");
module.exports = function() {
	var {Date, __ks_Date} = require("./implement.ctor.wseal.default.es6.ks")();
	const d1 = __ks_Date.new();
	const d2 = __ks_Date.new([2000, 1, 1]);
	const d3 = __ks_Date.new("2000-01-01");
	const d4 = __ks_Date.new(2000);
};
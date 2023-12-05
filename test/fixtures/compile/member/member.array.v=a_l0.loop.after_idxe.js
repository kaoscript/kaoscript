const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		const values = [];
		for(let i = 1; i <= 10; ++i) {
			if((i % 2) === 1) {
				values.push(i);
			}
			else {
				console.log(Helper.toString(values[0]));
			}
		}
		console.log(Helper.toString(values[0]));
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return foobar.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
};
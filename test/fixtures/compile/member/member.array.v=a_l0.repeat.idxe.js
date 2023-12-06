const {Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function() {
		const values = [];
		let i = 1;
		while(true) {
			values.push(i);
			if(i > 10) {
				break;
			}
			else {
				i += 1;
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
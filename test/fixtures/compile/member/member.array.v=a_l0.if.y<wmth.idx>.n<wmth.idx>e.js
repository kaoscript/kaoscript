const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(add) {
		const values = [];
		if(add === true) {
			values.push("foo", "bar");
			console.log(Helper.toString(values[0]));
		}
		else {
			values.push("qux");
			console.log(Helper.toString(values[0]));
		}
		console.log(Helper.toString(values[0]));
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
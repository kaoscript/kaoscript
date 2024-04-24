const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(test, x) {
		if(x === void 0 || x === null) {
			x = "jane";
		}
		if(test === true) {
			let x = "john";
			console.log(x);
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length >= 1 && args.length <= 2) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};
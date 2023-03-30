const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(Type.isDexObject(value, 1) && value.foo === 1 && Type.isDexObject(value, 0, 0, {qux: Type.isNumber})) {
			let {qux: n} = value;
			console.log(Helper.concatString("qux: ", n));
		}
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
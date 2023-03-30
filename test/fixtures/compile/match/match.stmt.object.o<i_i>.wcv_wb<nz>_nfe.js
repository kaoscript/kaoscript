const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(value.foo === 1) {
			let {qux: n} = value;
			console.log(Helper.concatString("qux: ", n));
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isDexObject(value, 2, 0, {foo: Type.isNumber, qux: Type.isNumber});
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		if(value.foo === 1 && Type.isDexObject(value, 0, 0, {qux: Type.isValue})) {
			let {qux: n} = value;
			console.log(Helper.concatString("qux: ", n));
		}
		else if(value.foo === 1) {
			console.log("foo: 1");
		}
		else if(!Type.isNull(value.foo)) {
			console.log("has foo");
		}
		else if(!Type.isNull(value.qux)) {
			console.log("has qux");
		}
		else if(value.bar() === 0) {
			console.log("bar() == 0");
		}
		else {
			console.log("oops!");
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isObject;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
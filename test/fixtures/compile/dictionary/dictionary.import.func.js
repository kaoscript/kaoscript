const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(f) {
		return f.foo();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isObject(value, void 0, {x: Type.isNumber, y: Type.isNumber, foo: Type.isFunction});
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
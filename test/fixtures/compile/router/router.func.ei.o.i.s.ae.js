const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Color = Helper.enum(Number, {
		Red: 0,
		Green: 1,
		Blue: 2
	});
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return "color";
	};
	foobar.__ks_1 = function(x) {
		return "object";
	};
	foobar.__ks_2 = function(x) {
		return "number";
	};
	foobar.__ks_3 = function(x) {
		return "string";
	};
	foobar.__ks_4 = function(x) {
		return "any";
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, Color);
		const t1 = Type.isNumber;
		const t2 = Type.isString;
		const t3 = Type.isObject;
		const t4 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_2.call(that, args[0]);
			}
			if(t2(args[0])) {
				return foobar.__ks_3.call(that, args[0]);
			}
			if(t3(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			if(t4(args[0])) {
				return foobar.__ks_4.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
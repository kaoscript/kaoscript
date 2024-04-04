const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isNamed: value => Type.isDexObject(value, 1, 0, {name: Type.isString}),
		isAged: value => __ksType.isNamed(value) && Type.isDexObject(value, 1, 0, {age: Type.isNumber})
	};
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		console.log(value.name);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = __ksType.isNamed;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(value, log) {
		log(value);
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isFunction;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return quxbaz.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	quxbaz.__ks_0((() => {
		const o = new OBJ();
		o.name = "Hello!";
		o.age = 0;
		return o;
	})(), Helper.curry((that, fn, ...args) => {
		const t0 = __ksType.isNamed;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fn[0](args[0]);
			}
		}
		throw Helper.badArgs();
	}, (__ks_0) => foobar.__ks_0(__ks_0)));
	quxbaz((() => {
		const o = new OBJ();
		o.name = "Hello!";
		return o;
	})(), console.log);
};
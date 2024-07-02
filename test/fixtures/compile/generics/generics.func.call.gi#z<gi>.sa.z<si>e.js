const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Named = Helper.alias((value, mapper) => Type.isDexObject(value, 1, 0, {name: () => true, age: Type.isNumber}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(name, age) {
		return (() => {
			const o = new OBJ();
			o.name = name;
			o.age = age;
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
	function quxbaz() {
		return quxbaz.__ks_rt(this, arguments);
	};
	quxbaz.__ks_0 = function(name, age) {
		return foobar(name, age);
	};
	quxbaz.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return quxbaz.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};
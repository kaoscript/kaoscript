const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const __ksType = {
		isTypeA: value => Type.isDexObject(value, 1, 0, {foobar: Type.isString}),
		isTypeB: value => Type.isDexObject(value, 1, 0, {quxbaz: Type.isNumber}),
		isTypeC: value => __ksType.isTypeA(value) && __ksType.isTypeB(value)
	};
	const StructA = Helper.struct(function(foobar, quxbaz) {
		const _ = new OBJ();
		_.foobar = foobar;
		_.quxbaz = quxbaz;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t1(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, StructA)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isString(arg = item.foobar)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isNumber(arg = item.quxbaz)) {
			return null;
		}
		args[1] = arg;
		return __ks_new.call(null, args);
	});
};
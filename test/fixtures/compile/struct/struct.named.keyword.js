const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(__ks_function_1) {
		const _ = new OBJ();
		_.function = __ks_function_1;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Foobar)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isNumber(arg = item.function)) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	const s = Foobar.__ks_new(42);
};
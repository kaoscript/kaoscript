const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(values) {
		const _ = new OBJ();
		_.values = values;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isDexObject(value, 1, Type.isString);
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
		if(!Type.isDexObject(arg = item.values, 1, Type.isString)) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	const foo = Foobar.__ks_new(new OBJ());
};
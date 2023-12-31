const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Event = Helper.struct(function(names) {
		const _ = new OBJ();
		_.names = names;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isArray(value, Type.isString);
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Event)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isArray(arg = item.names, Type.isString)) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	const e = Event.__ks_new([]);
};
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(x = null) {
		const _ = new OBJ();
		_.x = x;
		return _;
	}, function(__ks_new, args) {
		if(args.length <= 1) {
			return __ks_new(args[0]);
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
		if(!true) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	const f = Foobar.__ks_new("");
	f.x = null;
};
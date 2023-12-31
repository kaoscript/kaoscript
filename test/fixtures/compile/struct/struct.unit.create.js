const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Unit = Helper.struct(function() {
		return new OBJ();
	}, function(__ks_new, args) {
		if(args.length === 0) {
			return __ks_new();
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Unit)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		return __ks_new.call(null, args);
	});
	const unit = Unit.__ks_new();
};
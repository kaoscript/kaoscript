const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const FontWeight = Helper.enum(Number, 0, "Bold", 0, "Normal", 1);
	const Style = Helper.struct(function(fontWeight) {
		const _ = new OBJ();
		_.fontWeight = fontWeight;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isEnumInstance(value, FontWeight);
		if(args.length === 1) {
			if(t0(args[0])) {
				return __ks_new(args[0]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Style)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isEnumInstance(arg = item.fontWeight, FontWeight)) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	const bold = Style.__ks_new(FontWeight.Bold);
};
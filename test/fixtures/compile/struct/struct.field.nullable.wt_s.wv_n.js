const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(x = null) {
		const _ = new OBJ();
		_.x = x;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return __ks_new(Helper.getVararg(args, 0, pts[1]));
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
		if(!Type.isString(arg = item.x) || Type.isNull(arg = item.x)) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	const f = Foobar.__ks_new();
	f.x = null;
};
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Foobar = Helper.struct(function(qux = null) {
		const _ = new OBJ();
		_.qux = qux;
		return _;
	}, function(__ks_new, args) {
		const t0 = value => Type.isStructInstance(value, Quxbaz) || Type.isNull(value);
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
		if(!Type.isStructInstance(arg = item.qux, Quxbaz) || Type.isNull(arg = item.qux)) {
			return null;
		}
		args[0] = arg;
		return __ks_new.call(null, args);
	});
	const Quxbaz = Helper.struct(function(x, y) {
		const _ = new OBJ();
		_.x = x;
		_.y = y;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	}, function(__ks_new, item) {
		if(Type.isStructInstance(item, Quxbaz)) {
			return item;
		}
		if(!Type.isObject(item)) {
			return null;
		}
		const args = [];
		let arg;
		if(!Type.isValue(arg = item.x)) {
			return null;
		}
		args[0] = arg;
		if(!Type.isValue(arg = item.y)) {
			return null;
		}
		args[1] = arg;
		return __ks_new.call(null, args);
	});
	const point = Foobar.__ks_new();
	point.qux = Quxbaz.__ks_new(1, 1);
};
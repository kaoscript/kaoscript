const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Position = Helper.alias(value => Type.isDexObject(value, 1, 0, {line: Type.isNumber, column: Type.isNumber}));
	const Event = Helper.struct(function(ok, value = null, start = null, end = null) {
		const _ = new OBJ();
		_.ok = ok;
		_.value = value;
		_.start = start;
		_.end = end;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isBoolean;
		const t1 = Type.any;
		const t2 = value => Position.is(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 1 && args.length <= 4) {
			if(t0(args[0]) && Helper.isVarargs(args, 0, 1, t1, pts = [1], 0) && Helper.isVarargs(args, 0, 1, t2, pts, 1) && Helper.isVarargs(args, 0, 1, t2, pts, 2) && te(pts, 3)) {
				return __ks_new(args[0], Helper.getVararg(args, 1, pts[1]), Helper.getVararg(args, pts[1], pts[2]), Helper.getVararg(args, pts[2], pts[3]));
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
		if(!Type.isBoolean(arg = item.ok)) {
			return null;
		}
		args[0] = arg;
		if(!true) {
			return null;
		}
		args[1] = arg;
		if(!Position.is(arg = item.start)) {
			return null;
		}
		args[2] = arg;
		if(!Position.is(arg = item.end)) {
			return null;
		}
		args[3] = arg;
		return __ks_new.call(null, args);
	});
};
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Coord = Helper.struct(function(x, y, elevation) {
		const _ = new OBJ();
		_.x = x;
		_.y = y;
		_.elevation = elevation;
		return _;
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isObject(value, void 0, {unit: Type.isString, value: Type.isNumber});
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t1(args[2])) {
				return __ks_new(args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	});
	return {
		Coord
	};
};
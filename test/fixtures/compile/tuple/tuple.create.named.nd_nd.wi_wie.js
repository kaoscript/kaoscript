const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Point = Helper.tuple(function(x, y) {
		return [x, y];
	}, function(__ks_new, args) {
		const t0 = Type.isNumber;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return __ks_new(args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	});
	const point = Point.__ks_new(0, 0);
};
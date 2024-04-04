const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(__ks_JSON) {
	if(!__ks_JSON) {
		__ks_JSON = {};
	}
	__ks_JSON.foobar = function() {
		return __ks_JSON.foobar.__ks_rt(this, arguments);
	};
	__ks_JSON.foobar.__ks_0 = function(args) {
	};
	__ks_JSON.foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(Helper.isVarargs(args, 0, args.length, t0, pts = [0], 0) && te(pts, 1)) {
			return __ks_JSON.foobar.__ks_0.call(that, Helper.getVarargs(args, 0, pts[1]));
		}
		throw Helper.badArgs();
	};
	let coord = (() => {
		const o = new OBJ();
		o.x = 1;
		o.y = 1;
		return o;
	})();
	console.log(JSON.stringify(coord));
};
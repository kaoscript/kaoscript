const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function({x, y} = (() => {
		const d = new OBJ();
		d.x = "foo";
		d.y = "bar";
		return d;
	})()) {
		console.log(x + "." + y);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isObject(value, Type.isString) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length <= 1) {
			if(Helper.isVarargs(args, 0, 1, t0, pts = [0], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, Helper.getVararg(args, 0, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};
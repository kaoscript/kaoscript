const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z, d) {
		if(z === void 0) {
			z = null;
		}
		if(d === void 0 || d === null) {
			d = "";
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 3 && args.length <= 4) {
			if(t0(args[0]) && t0(args[1]) && t1(args[2]) && Helper.isVarargs(args, 0, 1, t1, pts = [3], 0) && te(pts, 1)) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2], Helper.getVararg(args, 3, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
	function corge() {
		return corge.__ks_rt(this, arguments);
	};
	corge.__ks_0 = function(metadatas) {
		for(const name in metadatas) {
			const data = metadatas[name];
			foobar(data.x, data.y, null, name);
		}
	};
	corge.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return corge.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
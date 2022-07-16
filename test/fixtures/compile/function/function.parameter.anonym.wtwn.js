const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function(data, __ks_0, name) {
		if(name === void 0 || name === null) {
			name = data.name;
		}
		console.log(name);
	};
	foo.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		const t1 = value => Type.isDictionary(value) || Type.isNull(value);
		const t2 = value => Type.isString(value) || Type.isNull(value);
		const te = (pts, idx) => Helper.isUsingAllArgs(args, pts, idx);
		let pts;
		if(args.length >= 2 && args.length <= 3) {
			if(t0(args[0]) && t1(args[1]) && Helper.isVarargs(args, 0, 1, t2, pts = [2], 0) && te(pts, 1)) {
				return foo.__ks_0.call(that, args[0], args[1], Helper.getVararg(args, 2, pts[1]));
			}
		}
		throw Helper.badArgs();
	};
};
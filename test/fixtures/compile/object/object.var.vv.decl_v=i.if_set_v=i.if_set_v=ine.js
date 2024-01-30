const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z) {
		if(z === void 0) {
			z = null;
		}
		const result = (() => {
			const o = new OBJ();
			o.x = x;
			return o;
		})();
		if(x === 0) {
			result.y = y;
		}
		if(x === 1) {
			result.z = z;
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		const t1 = value => Type.isNumber(value) || Type.isNull(value);
		if(args.length === 3) {
			if(t0(args[0]) && t0(args[1]) && t1(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};
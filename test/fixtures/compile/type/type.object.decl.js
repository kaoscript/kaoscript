const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z) {
		const xyz = (() => {
			const o = new OBJ();
			o.x = x;
			o.y = y;
			o.z = z;
			return o;
		})();
		return (() => {
			const o = new OBJ();
			o.x = xyz.x;
			o.y = xyz.y + 42;
			o.z = !xyz.z;
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isString;
		const t1 = Type.isNumber;
		const t2 = Type.isBoolean;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t2(args[2])) {
				return foobar.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
};
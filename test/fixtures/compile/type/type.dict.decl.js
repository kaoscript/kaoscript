const {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y, z) {
		const xyz = (() => {
			const d = new Dictionary();
			d.x = x;
			d.y = y;
			d.z = z;
			return d;
		})();
		return (() => {
			const d = new Dictionary();
			d.x = xyz.x;
			d.y = xyz.y + 42;
			d.z = !xyz.z;
			return d;
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
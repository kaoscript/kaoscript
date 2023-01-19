const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(z) {
		if(z === void 0) {
			z = null;
		}
		const point = (() => {
			const o = new OBJ();
			o.x = 1;
			o.y = 1;
			if(Type.isValue(z)) {
				o.z = z;
			}
			return o;
		})();
		return point;
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length === 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};
const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(value) {
		return Helper.assert((() => {
			const o = new OBJ();
			o.x = value.x;
			o.y = value.y;
			return o;
		})(), "\"{x: Any, y: Any}\"", 0, value => Type.isDexObject(value, 1, 0, {x: Type.isValue, y: Type.isValue}));
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
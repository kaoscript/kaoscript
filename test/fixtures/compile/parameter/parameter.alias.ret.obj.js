const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function() {
	const Coord = Helper.alias(value => Type.isDexObject(value, 1, 0, {x: Type.isNumber, y: Type.isNumber}));
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(coord) {
		const {x, y} = coord;
		return (() => {
			const o = new OBJ();
			o.x = x;
			o.y = y;
			return o;
		})();
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Coord.is;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
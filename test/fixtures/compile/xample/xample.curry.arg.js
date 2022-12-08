const {Helper, OBJ, Operator, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let o = (() => {
		const d = new OBJ();
		d.name = "White";
		return d;
	})();
	function fff() {
		return fff.__ks_rt(this, arguments);
	};
	fff.__ks_0 = function(prefix) {
		return Operator.add(prefix, this.name);
	};
	fff.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return fff.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	let f = Helper.vcurry(fff, o);
	let s = f("Hello ");
};
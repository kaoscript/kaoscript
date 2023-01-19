const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	function reset() {
		return reset.__ks_rt(this, arguments);
	};
	reset.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.x = 0;
			o.y = 0;
			return o;
		})();
	};
	reset.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return reset.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let point = (() => {
		const o = new OBJ();
		o.x = 1;
		o.y = 1;
		return o;
	})();
	point = reset.__ks_0();
};
const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	function reset() {
		return reset.__ks_rt(this, arguments);
	};
	reset.__ks_0 = function() {
		return (() => {
			const d = new OBJ();
			d.x = 0;
			d.y = 0;
			return d;
		})();
	};
	reset.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return reset.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let point = (() => {
		const d = new OBJ();
		d.x = 1;
		d.y = 1;
		return d;
	})();
	point = reset.__ks_0();
};
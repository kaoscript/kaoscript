const {Dictionary, Helper} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x = (() => {
		const d = new Dictionary();
		d.y = 42;
		return d;
	})()) {
	};
	foobar.__ks_rt = function(that, args) {
		if(args.length <= 1) {
			return foobar.__ks_0.call(that, args[0]);
		}
		throw Helper.badArgs();
	};
};
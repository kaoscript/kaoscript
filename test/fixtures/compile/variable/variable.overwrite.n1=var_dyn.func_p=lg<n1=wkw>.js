const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	let x = 42;
	function foo() {
		return foo.__ks_rt(this, arguments);
	};
	foo.__ks_0 = function([x]) {
	};
	foo.__ks_rt = function(that, args) {
		const t0 = value => Type.isDexArray(value, 1, 1, 0, 0, [Type.isValue]);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foo.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
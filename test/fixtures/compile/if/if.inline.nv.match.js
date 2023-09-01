const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x, y) {
		let name;
		if(x === true) {
			if(y === 0) {
				name = "zero";
			}
			else if(y === 1) {
				name = "one";
			}
			else {
				name = "bye";
			}
		}
		else {
			name = "bye";
		}
		console.log(name);
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 2) {
			if(t0(args[0]) && t0(args[1])) {
				return foobar.__ks_0.call(that, args[0], args[1]);
			}
		}
		throw Helper.badArgs();
	};
};
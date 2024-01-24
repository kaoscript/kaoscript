const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(temperature) {
		if(temperature >= 0 && temperature <= 49) {
			console.log("Cold");
		}
		else if(temperature >= 50 && temperature <= 79) {
			console.log("Warm");
		}
		else if(temperature >= 80 && temperature <= 110) {
			console.log("Hot");
		}
		else {
			console.log("Temperature out of range");
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isNumber;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
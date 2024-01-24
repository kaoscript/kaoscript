const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(temperature) {
		if(temperature >= 0 && temperature <= 49 && (temperature % 2) === 0) {
			console.log("Cold and even");
		}
		else if(temperature >= 50 && temperature <= 79 && (temperature % 2) === 0) {
			console.log("Warm and even");
		}
		else if(temperature >= 80 && temperature <= 110 && (temperature % 2) === 0) {
			console.log("Hot and even");
		}
		else {
			console.log("Temperature out of range or odd");
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
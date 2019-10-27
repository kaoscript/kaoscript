module.exports = function() {
	function foobar(d) {
		if(arguments.length < 1) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 1)");
		}
		if(d === void 0 || d === null) {
			throw new TypeError("'d' is not nullable");
		}
		let __ks_0 = () => {
			console.log("hour");
			__ks_1();
		};
		let __ks_1 = () => {
			console.log("minute");
			__ks_2();
		};
		let __ks_2 = () => {
			console.log("second");
		};
		if(d === "hour") {
			__ks_0();
		}
		else if(d === "minute") {
			__ks_1();
		}
		else if(d === "second") {
			__ks_2();
		}
	}
};
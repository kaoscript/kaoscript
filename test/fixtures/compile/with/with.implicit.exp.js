const {Helper, OBJ} = require("@kaoscript/runtime");
module.exports = function() {
	function load() {
		return load.__ks_rt(this, arguments);
	};
	load.__ks_0 = function() {
		return (() => {
			const o = new OBJ();
			o.firstname = "John";
			o.lastname = "Doe";
			return o;
		})();
	};
	load.__ks_rt = function(that, args) {
		if(args.length === 0) {
			return load.__ks_0.call(that);
		}
		throw Helper.badArgs();
	};
	let __ks_0 = load.__ks_0();
	console.log(Helper.concatString("Hello ", __ks_0.firstname, " ", __ks_0.lastname));
};
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	function update() {
		return update.__ks_rt(this, arguments);
	};
	update.__ks_0 = function(address) {
		if(Type.isValue(address)) {
			address.setStreet("Elm", "13a");
			address.city = "Carthage";
			address.state = "Eurasia";
			address.zip(66666, 6666);
		}
	};
	update.__ks_rt = function(that, args) {
		const t0 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return update.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
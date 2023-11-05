require("kaoscript/register");
const {Helper, Type} = require("@kaoscript/runtime");
module.exports = function() {
	var CardSuit = require("./.enum.junction.export.ks.j5k8r9.ksb")().CardSuit;
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(suit) {
		if(CardSuit.__ks_eq_Blacks(suit)) {
		}
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, CardSuit);
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
};
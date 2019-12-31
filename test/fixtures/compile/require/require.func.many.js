require("kaoscript/register");
var Type = require("@kaoscript/runtime").Type;
module.exports = function(reverse) {
	var __ks_Array = require("../_/_array.ks")().__ks_Array;
	var __ks_Number = require("../_/_number.ks")().__ks_Number;
	var __ks_String = require("../_/_string.ks")().__ks_String;
	const __ks_reverse_1 = reverse;
	function reverse() {
		if(arguments.length === 1 && Type.isNumber(arguments[0])) {
			let __ks_i = -1;
			let value = arguments[++__ks_i];
			if(value === void 0 || value === null) {
				return __ks_reverse_1(...arguments);
			}
			else if(!Type.isNumber(value)) {
				return __ks_reverse_1(...arguments);
			}
			return -value;
		}
		else {
			return __ks_reverse_1(...arguments);
		}
	};
	console.log(__ks_Number._im_mod(reverse(42), 16));
	console.log(__ks_String._im_toInt(reverse("42")));
	console.log(__ks_Array._im_last(reverse([1, 2, 3])));
	return {
		reverse: reverse
	};
};
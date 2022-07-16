const {Type} = require("@kaoscript/runtime");
module.exports = function(assert, Assertion, config, expect, should, Should, use) {
	var __ks_0_valuable = Type.isValue(assert);
	var __ks_1_valuable = Type.isValue(Assertion);
	var __ks_2_valuable = Type.isValue(config);
	var __ks_3_valuable = Type.isValue(expect);
	var __ks_4_valuable = Type.isValue(should);
	var __ks_5_valuable = Type.isValue(Should);
	var __ks_6_valuable = Type.isValue(use);
	if(!__ks_0_valuable || !__ks_1_valuable || !__ks_2_valuable || !__ks_3_valuable || !__ks_4_valuable || !__ks_5_valuable || !__ks_6_valuable) {
		var __ks__ = require("chai");
		if(!__ks_0_valuable) {
			assert = __ks__.assert;
		}
		if(!__ks_1_valuable) {
			Assertion = __ks__.Assertion;
		}
		if(!__ks_2_valuable) {
			config = __ks__.config;
		}
		if(!__ks_3_valuable) {
			expect = __ks__.expect;
		}
		if(!__ks_4_valuable) {
			should = __ks__.should;
		}
		if(!__ks_5_valuable) {
			Should = __ks__.Should;
		}
		if(!__ks_6_valuable) {
			use = __ks__.use;
		}
	}
};
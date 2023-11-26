const {Helper, OBJ, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	const CardSuit = Helper.enum(String, "Clubs", "clubs", "Diamonds", "diamonds", "Hearts", "hearts", "Spades", "spades");
	expect(Type.isEnum(CardSuit)).to.equal(true);
	const x = (() => {
		return CardSuit.Clubs;
	})();
	expect(Type.isEnumInstance(x, CardSuit)).to.equal(true);
	expect(Type.typeOf(x)).to.equal("enum-member");
	expect(Helper.concatString(">>> ", x)).to.equal(">>> clubs");
	expect(Helper.toString(x)).to.equal("clubs");
	expect(JSON.stringify((() => {
		const o = new OBJ();
		o.id = x;
		return o;
	})())).to.equal("{\"id\":\"clubs\"}");
	expect(JSON.stringify((() => {
		const o = new OBJ();
		o.id = x.value;
		return o;
	})())).to.equal("{\"id\":\"clubs\"}");
	function foobar() {
		return foobar.__ks_rt(this, arguments);
	};
	foobar.__ks_0 = function(x) {
		return "enum";
	};
	foobar.__ks_1 = function(x) {
		return "enum-member";
	};
	foobar.__ks_2 = function(x) {
		return "number";
	};
	foobar.__ks_3 = function(x) {
		return "dictionary";
	};
	foobar.__ks_4 = function(x) {
		return "string";
	};
	foobar.__ks_5 = function(x) {
		return "any";
	};
	foobar.__ks_rt = function(that, args) {
		const t0 = Type.isEnum;
		const t1 = Type.isNumber;
		const t2 = value => Type.isEnumInstance(value, CardSuit);
		const t3 = Type.isString;
		const t4 = Type.isObject;
		const t5 = Type.isValue;
		if(args.length === 1) {
			if(t0(args[0])) {
				return foobar.__ks_0.call(that, args[0]);
			}
			if(t1(args[0])) {
				return foobar.__ks_2.call(that, args[0]);
			}
			if(t2(args[0])) {
				return foobar.__ks_1.call(that, args[0]);
			}
			if(t3(args[0])) {
				return foobar.__ks_4.call(that, args[0]);
			}
			if(t4(args[0])) {
				return foobar.__ks_3.call(that, args[0]);
			}
			if(t5(args[0])) {
				return foobar.__ks_5.call(that, args[0]);
			}
		}
		throw Helper.badArgs();
	};
	expect(foobar.__ks_0(CardSuit)).to.equal("enum");
	expect(foobar.__ks_1(CardSuit.Clubs)).to.equal("enum-member");
	expect(foobar.__ks_4(CardSuit.Clubs.value)).to.equal("string");
	expect(foobar.__ks_2(0)).to.equal("number");
	expect(foobar.__ks_3(new OBJ())).to.equal("dictionary");
	expect(foobar.__ks_4("foo")).to.equal("string");
	function testIf() {
		return testIf.__ks_rt(this, arguments);
	};
	testIf.__ks_0 = function(x, y, z) {
		const results = [];
		if(x === CardSuit.Clubs) {
			results.push("c");
		}
		else {
			results.push(null);
		}
		if(y === CardSuit.Clubs.value) {
			results.push("c");
		}
		else {
			results.push(null);
		}
		if(z.valueOf() === CardSuit.Clubs.value) {
			results.push("c");
		}
		else {
			results.push(null);
		}
		results.push((x === CardSuit.Clubs) ? "c" : null);
		results.push((y === CardSuit.Clubs.value) ? "c" : null);
		results.push((z.valueOf() === CardSuit.Clubs.value) ? "c" : null);
		return results;
	};
	testIf.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, CardSuit);
		const t1 = Type.isString;
		const t2 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t2(args[2])) {
				return testIf.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	expect(testIf.__ks_0(CardSuit.Clubs, CardSuit.Clubs.value, CardSuit.Clubs)).to.eql(["c", "c", "c", "c", "c", "c"]);
	expect(testIf.__ks_0(CardSuit.Diamonds, CardSuit.Clubs.value, CardSuit.Clubs.value)).to.eql([null, "c", "c", null, "c", "c"]);
	function testSwitch() {
		return testSwitch.__ks_rt(this, arguments);
	};
	testSwitch.__ks_0 = function(x, y, z) {
		const results = [];
		if(x === CardSuit.Clubs) {
			results.push("c");
		}
		else if(x === CardSuit.Diamonds) {
			results.push("d");
		}
		else {
			results.push(null);
		}
		if(y === CardSuit.Clubs.value) {
			results.push("c");
		}
		else if(y === CardSuit.Diamonds.value) {
			results.push("d");
		}
		else {
			results.push(null);
		}
		let __ks_0 = Helper.valueOf(z);
		if(__ks_0 === CardSuit.Clubs.value) {
			results.push("c");
		}
		else if(__ks_0 === CardSuit.Diamonds.value) {
			results.push("d");
		}
		else {
			results.push(null);
		}
		return results;
	};
	testSwitch.__ks_rt = function(that, args) {
		const t0 = value => Type.isEnumInstance(value, CardSuit);
		const t1 = Type.isString;
		const t2 = Type.isValue;
		if(args.length === 3) {
			if(t0(args[0]) && t1(args[1]) && t2(args[2])) {
				return testSwitch.__ks_0.call(that, args[0], args[1], args[2]);
			}
		}
		throw Helper.badArgs();
	};
	expect(testSwitch.__ks_0(CardSuit.Clubs, CardSuit.Clubs.value, CardSuit.Clubs)).to.eql(["c", "c", "c"]);
	expect(testSwitch.__ks_0(CardSuit.Diamonds, CardSuit.Clubs.value, CardSuit.Clubs.value)).to.eql(["d", "c", "c"]);
};
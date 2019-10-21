var {Dictionary, Helper, Type} = require("@kaoscript/runtime");
module.exports = function(expect) {
	let CardSuit = Helper.enum(String, {
		Clubs: "clubs",
		Diamonds: "diamonds",
		Hearts: "hearts",
		Spades: "spades"
	});
	expect(Type.isEnum(CardSuit)).to.equal(true);
	const x = CardSuit.Clubs;
	expect(Type.isEnumMember(x, CardSuit)).to.equal(true);
	expect(Type.typeOf(x)).to.equal("enum-member");
	expect(">>> " + x).to.equal(">>> clubs");
	expect(x.value).to.equal("clubs");
	expect(JSON.stringify((() => {
		const d = new Dictionary();
		d.id = x;
		return d;
	})())).to.equal("{\"id\":\"clubs\"}");
	expect(JSON.stringify((() => {
		const d = new Dictionary();
		d.id = x.value;
		return d;
	})())).to.equal("{\"id\":\"clubs\"}");
	function foobar() {
		if(arguments.length === 1 && Type.isEnumMember(arguments[0], CardSuit)) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isEnumMember(x, CardSuit)) {
				throw new TypeError("'x' is not of type 'CardSuit'");
			}
			return "enum-member";
		}
		else if(arguments.length === 1 && Type.isEnum(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isEnum(x)) {
				throw new TypeError("'x' is not of type 'Enum'");
			}
			return "enum";
		}
		else if(arguments.length === 1 && Type.isNumber(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isNumber(x)) {
				throw new TypeError("'x' is not of type 'Number'");
			}
			return "number";
		}
		else if(arguments.length === 1 && Type.isString(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isString(x)) {
				throw new TypeError("'x' is not of type 'String'");
			}
			return "string";
		}
		else if(arguments.length === 1 && Type.isDictionary(arguments[0])) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			else if(!Type.isDictionary(x)) {
				throw new TypeError("'x' is not of type 'Dictionary'");
			}
			return "dictionary";
		}
		else if(arguments.length === 1) {
			let __ks_i = -1;
			let x = arguments[++__ks_i];
			if(x === void 0 || x === null) {
				throw new TypeError("'x' is not nullable");
			}
			return "any";
		}
		else {
			throw new SyntaxError("Wrong number of arguments");
		}
	};
	expect(foobar(CardSuit)).to.equal("enum");
	expect(foobar(CardSuit.Clubs)).to.equal("enum-member");
	expect(foobar(CardSuit.Clubs.value)).to.equal("string");
	expect(foobar(0)).to.equal("number");
	expect(foobar(new Dictionary())).to.equal("dictionary");
	expect(foobar("foo")).to.equal("string");
	function testIf(x, y, z) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isEnumMember(x, CardSuit)) {
			throw new TypeError("'x' is not of type 'CardSuit'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isString(y)) {
			throw new TypeError("'y' is not of type 'String'");
		}
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
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
	}
	expect(testIf(CardSuit.Clubs, CardSuit.Clubs.value, CardSuit.Clubs)).to.eql(["c", "c", "c", "c", "c", "c"]);
	expect(testIf(CardSuit.Diamonds, CardSuit.Clubs.value, CardSuit.Clubs.value)).to.eql([null, "c", "c", null, "c", "c"]);
	function testSwitch(x, y, z) {
		if(arguments.length < 3) {
			throw new SyntaxError("Wrong number of arguments (" + arguments.length + " for 3)");
		}
		if(x === void 0 || x === null) {
			throw new TypeError("'x' is not nullable");
		}
		else if(!Type.isEnumMember(x, CardSuit)) {
			throw new TypeError("'x' is not of type 'CardSuit'");
		}
		if(y === void 0 || y === null) {
			throw new TypeError("'y' is not nullable");
		}
		else if(!Type.isString(y)) {
			throw new TypeError("'y' is not of type 'String'");
		}
		if(z === void 0 || z === null) {
			throw new TypeError("'z' is not nullable");
		}
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
		let __ks_0 = z.valueOf();
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
	}
	expect(testSwitch(CardSuit.Clubs, CardSuit.Clubs.value, CardSuit.Clubs)).to.eql(["c", "c", "c"]);
	expect(testSwitch(CardSuit.Diamonds, CardSuit.Clubs.value, CardSuit.Clubs.value)).to.eql(["d", "c", "c"]);
};
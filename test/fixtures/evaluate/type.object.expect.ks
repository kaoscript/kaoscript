require expect: func

import '@kaoscript/test-import/src/external.js' => JS

class ClassA {
}

struct StructA {
}

tuple TupleA {
}

func id(x?) => x

func test(x: Object) => 'object'
func test(x?) => 'any'

expect(test(null)).to.equal('any', 'null')
expect(test(id(null))).to.equal('any', 'id(null)')
expect(test(true)).to.equal('any', 'boolean')
expect(test(id(true))).to.equal('any', 'id(boolean)')
expect(test(42)).to.equal('any', 'number')
expect(test(id(42))).to.equal('any', 'id(number)')
expect(test('foobar')).to.equal('any', 'string')
expect(test(id('foobar'))).to.equal('any', 'id(string)')
expect(test(/foobar/)).to.equal('object', 'regex')
expect(test(id(/foobar/))).to.equal('object', 'id(regex)')
expect(test([])).to.equal('any', 'array')
expect(test(id([]))).to.equal('any', 'id(array)')
expect(test({})).to.equal('object', 'dict')
expect(test(id({}))).to.equal('object', 'id(dict)')
expect(test(test)).to.equal('any', 'func')
expect(test(id(test))).to.equal('any', 'id(func)')
expect(test(ClassA)).to.equal('any', 'class')
expect(test(id(ClassA))).to.equal('any', 'id(class)')
expect(test(new ClassA())).to.equal('object', 'class-instance')
expect(test(id(new ClassA()))).to.equal('object', 'id(class-instance)')
expect(test(StructA)).to.equal('any', 'struct')
expect(test(id(StructA))).to.equal('any', 'id(struct)')
expect(test(StructA())).to.equal('object', 'struct-instance')
expect(test(id(StructA()))).to.equal('object', 'id(struct-instance)')
expect(test(TupleA)).to.equal('any', 'tuple')
expect(test(id(TupleA))).to.equal('any', 'id(tuple)')
expect(test(TupleA())).to.equal('any', 'tuple-instance')
expect(test(id(TupleA()))).to.equal('any', 'id(tuple-instance)')
expect(test(JS.object)).to.equal('object', 'js(object)')
expect(test(JS.ClassA)).to.equal('any', 'js(class)')
expect(test(new JS.ClassA())).to.equal('object', 'class-instance(js)')
expect(test(id(new JS.ClassA()))).to.equal('object', 'id(class-instance(js))')
expect(test(JS.instanceA)).to.equal('object', 'js(class-instance)')
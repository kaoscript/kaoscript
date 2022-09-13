require expect: func

var mut mode = 2
var mut index = 0

index += 1
expect(mode).to.eql(2)
expect(index).to.eql(1)

with mode += 12 {
	index += 1
	expect(mode).to.eql(14)
	expect(index).to.eql(2)

	mode -= 4

	index += 1
	expect(mode).to.eql(10)
	expect(index).to.eql(3)
}

index += 1
expect(mode).to.eql(2)
expect(index).to.eql(4)

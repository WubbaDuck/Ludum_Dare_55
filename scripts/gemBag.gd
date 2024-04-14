extends TextureRect

var gems = []

func addToBag(gem):
	gems.append(gem)

func emptyBag():
	gems.clear()

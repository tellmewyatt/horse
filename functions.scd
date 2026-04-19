~colorPad = { | nn, color |
	if(color == nil) {
		var alternate = nn.asString[0].digit % 2;
		if(nn + alternate % 2 == 0) {
			color = 120
		}
		{
			color = 21
		}
	};
	~lpxOut.noteOn(0, nn,  color);
};

~colorAllPads = { | function |
	8.collect { | row |
		8.collect { | col |
			var nn = row * 10 + col + 11;
			~colorPad.(nn);
		}
	}
};
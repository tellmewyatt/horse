MIDIIn.connectAll;
~lpxOut = MIDIOut.newByName("Launchpad X", "LPX MIDI In");
~lpxOut.latency = 0;
~noteMap = (
	noteMaps: ~noteMap.noteMaps ? (),
	current: ~noteMap.current,
	switchTo: { | self, name |
		self.current = self.noteMaps[name];
		self.noteMaps.postln;
		self;
	},
	def: { | self, name, func |
		var newMap = (
			onMap: (),
			toggleMap: (),
			offMap: ()
		);
		// Executes the creation function
		func.(
			(
				// Binds this note number and function to be played one off
				hit: { | innerSelf, nn, func |
					newMap.onMap[nn] = func;
				},
				// Binds this note number and function to be sustained
				sustain: { | innerSelf, nn, func |
					newMap.onMap[nn] = { | vel |
						newMap.offMap[nn] = func.(vel);
					};
				},
				// Binds this note number and function to be toggled
				toggle: { | innerSelf, nn, func |
					newMap.onMap[nn] = { | vel |
						if (newMap.toggleMap[nn] == nil) {
							newMap.toggleMap[nn] = func.();
							~colorPad.(nn, 50);
						} {
							newMap.toggleMap[nn].release;
							newMap.toggleMap[nn] = nil;
						}
					}
				},
				// Allows switching maps
				switchTo: { | innerSelf, key |
					self.current = self.noteMaps[key]
				}
			)
		);
		self.noteMaps[name] = newMap;
	},
	colorPad: { | self, nn, color |
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
);
MIDIdef.noteOn(\noteOns, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	[nn, vel].postln;
	nn.postln;
	~noteMap.colorPad(nn, rrand(0, 127));
	~noteMap.current.onMap[nn].(vel / 127);
});
MIDIdef.noteOff(\noteOffs, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	nn.postln;
	if (~noteMap.current.toggleMap[nn] == nil) {
		~noteMap.colorPad(nn);
		~noteMap.current.offMap[nn].release;
		~noteMap.current.offMap[nn] = nil;
	};
});
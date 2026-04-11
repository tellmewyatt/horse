MIDIIn.connectAll;
~lpxOut = MIDIOut.newByName("Launchpad X", "LPX MIDI In");
~lpxOut.latency = 0;
~noteMap = (
	noteMaps: if(~noteMap != nil) { ~noteMap.noteMaps } { () },
	currentPointer: if(~noteMap != nil) { ~noteMap.currentPointer } { nil },
	current: { | self | self.noteMaps[self.currentPointer] },
	switchTo: { | self, name |
		self.currentPointer = name;
	},
	def: { | self, name, func |
		var newMap = (
			onMap: (),
			toggleMap: (),
			toggleOffMap: (),
			offMap: (),
			getPadColor: {},
			getPadColorActive: {}
		);
		// Executes the creation function
		func.(
			(
				// Binds this note number and function to be played one off
				hit: { | innerSelf, nn, func |
					newMap.onMap[nn] = { | vel |
						newMap.offMap[nn] = 1;
						func.(vel);
					};
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
							newMap.toggleMap[nn] = func.(vel, self.current);
						} {
							self.colorPad(nn, newMap.getPadColor(nn));
							newMap.toggleMap[nn].release;
							newMap.toggleMap[nn] = nil;
						};
						// Set any additional action for when toggled off
						if(newMap.toggleOffMap[nn] != nil) {
							newMap.toggleOffMap[nn].(vel, self.current)
						}
					}
				},
				// Function to be called after item is released;
				toggleOff: { | innerSelf, nn, func |
					newMap.toggleOffMap[nn] = func;
				},
				// Allows switching maps
				switchTo: { | innerSelf, key |
					self.current.offMap.keys.collect { | nn |
						self.colorPad(nn, self.current.getPadColor(nn));
						self.current.offMap[nn].release;
						self.current.offMap[nn] = nil;
					};
					self.current = self.noteMaps[key]
				},
				current: self.current,
				// Accepts a callback func(nn)
				colorPad: { | innerSelf, func |
					newMap.getPadColor = { | self, nn | func.(nn) };
				},
				// Accepts a callback func(nn)
				colorPadActive: { | innerSelf, func |
					newMap.getPadColorActive = { | self, nn | func.(nn) };
				}
			)
		);
		self.noteMaps[name] = newMap;
	},
	colorPad: { | self, nn, color |
		~lpxOut.noteOn(0, nn,  color.asInteger);
	},
	colorPadActive: { | self, nn, color |
		~lpxOut.noteOn(0, nn,  color.asInteger);
	},
	colorAllPads: { | self |
		8.collect { | row |
			8.collect { | col |
				var nn = row * 10 + col + 11;
				self.colorPad(nn, self.current.getPadColor(nn));
			}
		}
	};
);
MIDIdef.noteOn(\noteOns, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	[nn, vel].postln;
	~noteMap.colorPad(nn, ~noteMap.current.getPadColorActive(nn));
	~noteMap.current.onMap[nn].(vel / 127);
});
MIDIdef.noteOff(\noteOffs, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	if(~noteMap.current.offMap[nn] != nil) {
		~noteMap.colorPad(nn, ~noteMap.current.getPadColor(nn));
		~noteMap.current.offMap[nn].release;
		~noteMap.current.offMap[nn] = nil;
	}
});
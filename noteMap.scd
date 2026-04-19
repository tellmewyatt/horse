MIDIIn.connectAll;
~lpxOut = MIDIOut.newByName("Launchpad X", "LPX MIDI In");
~lpxOut.latency = 0;
~noteMap = (
	noteMaps: if(~noteMap != nil) { ~noteMap.noteMaps } { () },
	currentPointer: if(~noteMap != nil) { ~noteMap.currentPointer } { nil },
	current: { | self | self.noteMaps[self.currentPointer] },
	switchTo: { | self, key |
		if(self.current.notNil) {
			self.current.offMap.keys.collect { | nn |
				self.colorPad(nn, self.current.getPadColor(nn));
				self.current.offMap[nn].release;
				self.current.offMap[nn] = nil;
			};
			self.current.onReset;
		};
		self.currentPointer = key;
		self.colorAllPads;

	},
	def: { | self, name, func |
		var newMap = (
			onMap: (),
			toggleMap: (),
			toggleOffMap: (),
			offMap: (),
			getPadColor: {},
			getPadColorActive: {},
			onReset: {},
			rowControl: {}
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
							self.colorPad(nn, ~noteMap.current.getPadColorActive(nn));
						} {
							newMap.toggleMap[nn].release;
							newMap.toggleMap[nn] = nil;
							self.colorPad(nn, newMap.getPadColor(nn));
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
					self.switchTo(key);
				},
				current: { self.current },
				// Accepts a callback func(nn)
				colorPad: { | innerSelf, func |
					newMap.getPadColor = { | self, nn | func.(nn) };
				},
				// Accepts a callback func(nn)
				colorPadActive: { | innerSelf, func |
					newMap.getPadColorActive = { | self, nn | func.(nn) };
				},
				// Function called to reset this map
				onReset: { | innerSelf, func |
					newMap.onReset = { | self | func.() };
				},
				// Callback for whenever any of the right hand buttons are pressed
				rowControl: { | innerSelf, func |
					newMap.rowControl = { | self, row | func.(row) };
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
	},
	midiNoteOn: { | self, nn, vel |
		self.colorPad(nn, self.current.getPadColorActive(nn));
		self.current.onMap[nn].(vel / 127);
	},
	midiNoteOff: { | self, nn, vel |
		if(self.current.offMap[nn] != nil) {
			self.colorPad(nn, self.current.getPadColor(nn));
			self.current.offMap[nn].release;
			self.current.offMap[nn] = nil;
		}
	}
);
MIDIdef.noteOn(\noteOns, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	[nn, vel].postln;
	~noteMap.midiNoteOn(nn, vel);

});
MIDIdef.noteOff(\noteOffs, { arg ...args;
	var nn = args[1];
	var vel = args[0];
	~noteMap.midiNoteOff(nn, vel);

});
MIDIdef.cc(\control, { | onOff, rowCol |
	var keys = ~noteMap.noteMaps.keys.asArray.sort;
	if(onOff == 127) {
		// Switch maps if in the top row
		if(rowCol.asString[0].digit == 9) {
			var index = rowCol - 91;
			var key = keys[index].postln;
			if(key.notNil) {
				~noteMap.switchTo(key);
			};
		} {
			~noteMap.current.rowControl(rowCol.asString[0].digit);
		}
	}
});
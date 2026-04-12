~noteMap.def(\b, { | m |
	// Turns off the previously held notes if they are on
	var getCol5Func = { | freq |
		{ | vel | Synth(\meoCircles, [\bufnum, ~samples.meo, \playbackRate, freq/205]); }
	};
	var enabledRows = Set();
	var toggleGroups = ();
	var togglePrevious = { | nn, vel |
		var map = ~noteMap.noteMaps.a;
		if(map.toggleMap[nn].notNil) {
			map.onMap[nn].(vel);
		};
	};
	var getBellFunc = { | nn, freq |
		{ | vel|
			var synths;
			var row = nn.asString[0].digit;
			if(toggleGroups[nn].isNil) {
				toggleGroups[nn] = Group(s);
				synths = toggleGroups[nn];
			};
			synths = toggleGroups[nn];
			Synth(\sinFmHit, [\freq, freq, \amp, 0.8 * vel, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)], synths);
			Synth(\sinFmHit, [\freq, freq * [-0.33, 0.33].choose.midiratio, \amp, 0.8 * vel, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)], synths);
			synths;
		}
	};
	var getBellReleaseFunc = { | freq |
		{ | vel |
			Synth(\sinFmHit, [\freq, freq, \amp, 0.8 * vel, \cmRatio, 3.5, \modIndex, 2.2, \release, 0.4, \pan, rrand(-1.0, 1)]);
			Synth(\sinFmHit, [\freq, freq * [-0.33, 0.33].choose.midiratio, \amp, 0.8 * vel, \cmRatio, 3.52, \modIndex, 2.2, \release, 0.4, \pan, rrand(-1.0, 1)]);
		}
	};
	~enabledRows = Set();
	m.hit(18, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(28, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(38, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);

	});
	m.hit(48, { | vel |
		Synth(\sinFmHit, [\freq, 800, \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(58, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.hit(68, { | vel |
		Synth(\sinFmHit, [\freq, 800 * 7.midiratio , \amp, 0.8, \cmRatio, 3.5, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
		Synth(\sinFmHit, [\freq, 810 * 7.midiratio, \amp, 0.8, \cmRatio, 3.52, \modIndex, 2.2, \release, 5, \pan, rrand(-1.0, 1)]);
	});
	m.toggle(71, { | vel |
		Synth(\sinPulse, [\freq, 50, \pan, rrand(-1.0, 1), \distortionFactor, 20]);
	});
	m.toggle(72, { | vel |
		Synth(\meoCircles, [\bufnum, ~samples.meo]);
	});
	m.toggle(76, getBellFunc.(88, 800 * 2.25.midiratio));
	m.toggleOff(76, getBellReleaseFunc.(800 * 2.25.midiratio));
	m.toggle(77, getBellFunc.(88, 800 * 5.25.midiratio));
	m.toggleOff(77, getBellReleaseFunc.(800 * 5.25.midiratio));
	m.toggle(78, getBellFunc.(88, 800 * 7.midiratio));
	m.toggleOff(78, getBellReleaseFunc.(800 * 7.midiratio));

	m.toggle(81, { | vel | Synth(\sinFmHit, [\freq, 100, \amp, vel * 1.6, \cmRatio, 3.5, \modIndex, 0.5, \release, 10, \pan, rrand(-1.0, 1)]); });
	m.toggleOff(81, getBellReleaseFunc.(100));
	m.toggle(82, getBellFunc.(82, 150));
	m.toggleOff(82, getBellReleaseFunc.(150));
	m.toggle(83, getBellFunc.(83, 200));
	m.toggleOff(83, getBellReleaseFunc.(200));
	m.toggle(84, getBellFunc.(83, 200));
	m.toggleOff(84, getBellReleaseFunc.(200));
	m.toggle(86, getBellFunc.(86, 800));
	m.toggle(87, getBellFunc.(87, 800 * 1.5.midiratio));
	m.toggleOff(87, getBellReleaseFunc.(800 * 1.5.midiratio));
	m.toggle(88, getBellFunc.(88, 800 * 3.75.midiratio));
	m.toggleOff(88, getBellReleaseFunc.(800 * 3.75.midiratio));

	// Column 5
	m.toggle(15, getCol5Func.(200));
	m.toggle(25, getCol5Func.(300));
	m.toggle(35, getCol5Func.(350));
	m.toggle(45, getCol5Func.(266));
	m.toggle(55, getCol5Func.(295));
	m.toggle(65, getCol5Func.(400));
	m.toggle(75, getCol5Func.(420));
	m.toggle(85, { | vel, current |
		var synth = getCol5Func.(490).(vel, current);
		synth;
	});

	// Column 9
	m.rowControl({ | row |
		~enabledRows.add(row);
		togglePrevious.(row * 10 + 5);
		(1..8).do { | i |
			var nn = row * 10 + i;
			nn.postln;
			if(m.current.toggleMap[nn].isNil) {
				~noteMap.colorPad(nn, m.current.getPadColor(nn));
			};
		};
	});
	// Pad Colors
	m.colorPad({ | nn |
		var color;
		var alternate = nn.asString[0].digit % 2;
		if(nn + alternate % 2 == 0) {
			color = 120
		}
		{
			color = 21
		};
		if(~enabledRows.includes(nn.asString[0].digit)) {
			color = ~config.enabledRowColor;
		};
		color;
	});
	m.colorPadActive({ | nn |
		var color = rrand(0, 127);
		if(m.current.toggleMap[nn].notNil) {
			color = ~config.toggledPadColor;
		};
		color;
	});
	// Callback to reset this to opening
	m.onReset({
		~enabledRows = Set();
		toggleGroups.collect { | g |
			g.free;
		};
		toggleGroups = ();
	});
});
return {
	['testburger'] = {
		label = 'Test Burger',
		weight = 220,
		degrade = 60,
		client = {
			image = 'burger_chicken.png',
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			export = 'ox_inventory_examples.testburger'
		},
		server = {
			export = 'ox_inventory_examples.testburger',
			test = 'what an amazingly delicious burger, amirite?'
		},
		buttons = {
			{
				label = 'Lick it',
				action = function(slot)
					print('You licked the burger')
				end
			},
			{
				label = 'Squeeze it',
				action = function(slot)
					print('You squeezed the burger :(')
				end
			},
			{
				label = 'What do you call a vegan burger?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('A misteak.')
				end
			},
			{
				label = 'What do frogs like to eat with their hamburgers?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('French flies.')
				end
			},
			{
				label = 'Why were the burger and fries running?',
				group = 'Hamburger Puns',
				action = function(slot)
					print('Because they\'re fast food.')
				end
			}
		},
		consume = 0.3
	},

	['bandage'] = {
		label = 'Bandage',
		weight = 115,
		client = {
			anim = { dict = 'missheistdockssetup1clipboard@idle_a', clip = 'idle_a', flag = 49 },
			prop = { model = `prop_rolled_sock_02`, pos = vec3(-0.14, -0.14, -0.08), rot = vec3(-50.0, -50.0, 0.0) },
			disable = { move = true, car = true, combat = true },
			usetime = 2500,
		}
	},

	['backpack_small'] = {
		label = 'Small Backpack',
		weight = 900,
		stack = false,
		close = false,
		consume = 0,
		description = 'A compact everyday backpack with 6x5 storage.',
		client = { image = 'backpack_small.png' }
	},

	['backpack_medium'] = {
		label = 'Backpack',
		weight = 1300,
		stack = false,
		close = false,
		consume = 0,
		description = 'A practical everyday backpack with 7x6 storage.',
		client = { image = 'backpack_medium.png' }
	},

	['backpack_large'] = {
		label = 'Large Backpack',
		weight = 1900,
		stack = false,
		close = false,
		consume = 0,
		description = 'A larger backpack with 8x7 storage for work, travel, or long days in the city.',
		client = { image = 'backpack_large.png' }
	},

	['black_money'] = {
		label = 'Dirty Money',
	},

	['burger'] = {
		label = 'Burger',
		weight = 220,
		client = {
			status = { hunger = 200000 },
			anim = 'eating',
			prop = 'burger',
			usetime = 2500,
			notification = 'You ate a delicious burger'
		},
	},

	['sandwich'] = {
		label = 'Deli Sandwich',
		weight = 250,
		client = {
			image = 'sandwich.png',
			status = { hunger = 250000 },
			anim = 'eating',
			usetime = 2500,
			cancel = true,
			notification = 'You ate a deli sandwich'
		}
	},

	['donut'] = {
		label = 'Donut',
		weight = 150,
		client = {
			image = 'donut.png',
			status = { hunger = 150000 },
			anim = 'eating',
			usetime = 2000,
			cancel = true,
			notification = 'You ate a donut'
		}
	},

	['chocolate_bar'] = {
		label = 'Chocolate Bar',
		weight = 100,
		client = {
			image = 'chocolate_bar.png',
			status = { hunger = 120000 },
			anim = 'eating',
			usetime = 1800,
			cancel = true,
			notification = 'You ate a chocolate bar'
		}
	},

	['chips'] = {
		label = 'Bag of Chips',
		weight = 150,
		client = {
			image = 'chips.png',
			status = { hunger = 120000 },
			anim = 'eating',
			usetime = 2000,
			cancel = true,
			notification = 'You ate some chips'
		}
	},

	['energy_drink'] = {
		label = 'Energy Drink',
		weight = 350,
		client = {
			image = 'energy_drink.png',
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank an energy drink'
		}
	},

	-- AVID CONVENIENCE STORE ITEMS -------------------------------------------------

	['slickers'] = {
		label = 'Slickers',
		weight = 90,
		stack = true,
		close = true,
		client = {
			image = 'snikkel_candy.png',
			status = { hunger = 90000, stress = -25000 },
			anim = 'eating',
			usetime = 1800,
			cancel = true,
			notification = 'You ate a Slickers bar'
		}
	},

	['twerks'] = {
		label = 'Twerks',
		weight = 95,
		stack = true,
		close = true,
		client = {
			image = 'twerks_candy.png',
			status = { hunger = 110000, stress = -30000 },
			anim = 'eating',
			usetime = 1800,
			cancel = true,
			notification = 'You ate a Twerks bar'
		}
	},

	['phat_chips'] = {
		label = 'Phat Chips',
		weight = 145,
		stack = true,
		close = true,
		client = {
			image = 'phatchips_bigcheese.png',
			status = { hunger = 180000, stress = -20000 },
			anim = 'eating',
			usetime = 2200,
			cancel = true,
			notification = 'You ate a bag of Phat Chips'
		}
	},

	['egochaser_bar'] = {
		label = 'EgoChaser Energy Bar',
		weight = 85,
		stack = true,
		close = true,
		client = {
			image = 'ego_chaser.png',
			status = { hunger = 150000, stress = -40000 },
			anim = 'eating',
			usetime = 1800,
			cancel = true,
			notification = 'You ate an EgoChaser bar'
		}
	},

	['noodle_cup'] = {
		label = 'Noodle Cup',
		weight = 420,
		stack = true,
		close = true,
		client = {
			image = 'noodlecup.png',
			status = { hunger = 280000, thirst = 30000, stress = -20000 },
			anim = 'eating',
			usetime = 3500,
			cancel = true,
			notification = 'You finished a cup of noodles'
		}
	},

	['veggie_wrap'] = {
		label = 'Veggie Wrap',
		weight = 330,
		stack = true,
		close = true,
		client = {
			image = 'veggiewrap.png',
			status = { hunger = 320000, thirst = 20000, stress = -15000 },
			anim = 'eating',
			usetime = 3200,
			cancel = true,
			notification = 'You ate a veggie wrap'
		}
	},

	['hotdog_plain'] = {
		label = 'Hotdog',
		weight = 360,
		stack = true,
		close = true,
		client = {
			image = 'hotdog_plain.png',
			status = { hunger = 360000, stress = -20000 },
			anim = 'eating',
			usetime = 3200,
			cancel = true,
			notification = 'You ate a hotdog'
		}
	},

	['apple_juice'] = {
		label = 'Apple Juice',
		weight = 380,
		stack = true,
		close = true,
		client = {
			image = 'juice_apple.png',
			status = { thirst = 260000, hunger = 30000, stress = -10000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some apple juice'
		}
	},

	['ecola'] = {
		label = 'eCola',
		weight = 350,
		stack = true,
		close = true,
		client = {
			image = 'ecola.png',
			status = { thirst = 240000, stress = -30000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ecola_can`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank an eCola'
		}
	},

	['ecola_light'] = {
		label = 'eCola Light',
		weight = 350,
		stack = true,
		close = true,
		client = {
			image = 'ecola_light.png',
			status = { thirst = 210000, stress = -20000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ecola_can`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank an eCola Light'
		}
	},

	['junk_drink'] = {
		label = 'Junk Energy Drink',
		weight = 350,
		stack = true,
		close = true,
		client = {
			image = 'junkdrink.png',
			status = { thirst = 320000, stress = -50000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank a Junk Energy Drink'
		}
	},

	['orangotang'] = {
		label = 'Orang-O-Tang',
		weight = 350,
		stack = true,
		close = true,
		client = {
			image = 'orangotang.png',
			status = { thirst = 280000, hunger = 20000, stress = -20000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank an Orang-O-Tang'
		}
	},

	['raine'] = {
		label = 'Raine',
		weight = 500,
		stack = true,
		close = true,
		client = {
			image = 'raine.png',
			status = { thirst = 360000, stress = -15000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank a bottle of Raine'
		}
	},

	['sprunk_light'] = {
		label = 'Sprunk Light',
		weight = 350,
		stack = true,
		close = true,
		client = {
			image = 'sprunklight.png',
			status = { thirst = 220000, stress = -20000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank a Sprunk Light'
		}
	},

	['redwood_cigarettes'] = {
		label = 'Redwood Cigarettes',
		weight = 200,
		stack = true,
		close = true,
		consume = 0.05,
		client = {
			image = 'cigsredwood1.png',
			status = { stress = -120000 },
			anim = { dict = 'amb@world_human_smoking@male@male_a@enter', clip = 'enter' },
			prop = { model = `prop_cs_ciggy_01`, pos = vec3(0.015, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 3000,
			cancel = true,
			notification = 'You smoked a Redwood'
		}
	},

	['cigs_69'] = {
		label = '69 Brand Cigarettes',
		weight = 200,
		stack = true,
		close = true,
		consume = 0.05,
		client = {
			image = 'cigs_69.png',
			status = { stress = -100000 },
			anim = { dict = 'amb@world_human_smoking@male@male_a@enter', clip = 'enter' },
			prop = { model = `prop_cs_ciggy_01`, pos = vec3(0.015, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 3000,
			cancel = true,
			notification = 'You smoked a 69 Brand cigarette'
		}
	},

	['homies_cigars'] = {
		label = 'Homies Cigars',
		weight = 220,
		stack = true,
		close = true,
		consume = 0.10,
		client = {
			image = 'cigars_homies.png',
			status = { stress = -180000 },
			anim = { dict = 'amb@world_human_smoking@male@male_a@enter', clip = 'enter' },
			prop = { model = `prop_cigar_02`, pos = vec3(0.015, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 4500,
			cancel = true,
			notification = 'You smoked a Homies cigar'
		}
	},

	['ambeer'] = {
		label = 'A.M. Beer',
		weight = 500,
		stack = true,
		close = true,
		client = {
			image = 'beer_ambeer.png',
			status = { thirst = 100000, stress = -50000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_amb_beer_bottle`, pos = vec3(0.01, 0.01, -0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 3500,
			cancel = true,
			notification = 'You drank an A.M. Beer'
		}
	},

	['dusche_beer'] = {
		label = 'Dusche Gold',
		weight = 500,
		stack = true,
		close = true,
		client = {
			image = 'beer_dusche.png',
			status = { thirst = 110000, stress = -60000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_amb_beer_bottle`, pos = vec3(0.01, 0.01, -0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 3500,
			cancel = true,
			notification = 'You drank a Dusche Gold'
		}
	},

	['logger_beer'] = {
		label = 'Logger Beer',
		weight = 500,
		stack = true,
		close = true,
		client = {
			image = 'beer_logger.png',
			status = { thirst = 90000, stress = -70000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_amb_beer_bottle`, pos = vec3(0.01, 0.01, -0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 3500,
			cancel = true,
			notification = 'You drank a Logger Beer'
		}
	},

	['pisswasser'] = {
		label = 'Pißwasser',
		weight = 500,
		stack = true,
		close = true,
		client = {
			image = 'beer_pisswaser.png',
			status = { thirst = 120000, stress = -65000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_amb_beer_bottle`, pos = vec3(0.01, 0.01, -0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 3500,
			cancel = true,
			notification = 'You drank a Pißwasser'
		}
	},

	['beer'] = {
		label = 'Beer',
		weight = 500,
		stack = true,
		close = true,
		consume = 1,
		description = 'A cold bottle of beer.',
		client = {
			image = 'sprunk.png',
			status = { thirst = 100000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_amb_beer_bottle`, pos = vec3(0.01, 0.01, -0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 3500,
			cancel = true,
			notification = 'You drank a cold beer'
		}
	},

	['cigarettes'] = {
		label = 'Cigarettes',
		weight = 200,
		consume = 0.05,
		client = {
			image = 'cigarettes.png',
			status = { stress = -100000 },
			anim = { dict = 'amb@world_human_smoking@male@male_a@enter', clip = 'enter' },
			prop = { model = `prop_cs_ciggy_01`, pos = vec3(0.015, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
			usetime = 2500,
			cancel = true,
			notification = 'You smoked a cigarette'
		}
	},

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		stack = true,
		close = true,
		client = {
			image = 'sprunk.png',
			status = { thirst = 250000, stress = -30000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank a Sprunk'
		}
	},

	['parachute'] = {
		label = 'Parachute',
		weight = 8000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 1500
		}
	},

	['garbage'] = {
		label = 'Garbage',
	},

	['paperbag'] = {
		label = 'Paper Bag',
		weight = 1,
		stack = false,
		close = false,
		consume = 0
	},

	['identification'] = {
		label = 'Identification',
		client = {
			image = 'card_id.png'
		}
	},

	['panties'] = {
		label = 'Knickers',
		weight = 10,
		consume = 0,
		client = {
			status = { thirst = -100000, stress = -25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_cs_panties_02`, pos = vec3(0.03, 0.0, 0.02), rot = vec3(0.0, -13.5, -1.5) },
			usetime = 2500,
		}
	},

	['lockpick'] = {
		label = 'Lockpick',
		weight = 160,
	},

	['phone'] = {
		label = 'Phone',
		weight = 190,
		stack = false,
		consume = 0,
		client = {
			add = function(total)
				if total > 0 then
					pcall(function() return exports.npwd:setPhoneDisabled(false) end)
				end
			end,

			remove = function(total)
				if total < 1 then
					pcall(function() return exports.npwd:setPhoneDisabled(true) end)
				end
			end
		}
	},

	['money'] = {
		label = 'Money',
	},

	['mustard'] = {
		label = 'Mustard',
		weight = 500,
		client = {
			status = { hunger = 25000, thirst = 25000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_food_mustard`, pos = vec3(0.01, 0.0, -0.07), rot = vec3(1.0, 1.0, -1.5) },
			usetime = 2500,
			notification = 'You.. drank mustard'
		}
	},

	['water'] = {
		label = 'Water',
		weight = 500,
		stack = true,
		close = true,
		client = {
			image = 'water_bottle.png',
			status = { thirst = 300000, stress = -10000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some water'
		}
	},

	['radio'] = {
		label = 'Radio',
		weight = 1000,
		stack = false,
		allowArmed = true
	},

	['armour'] = {
		label = 'Bulletproof Vest',
		weight = 3000,
		stack = false,
		client = {
			anim = { dict = 'clothingshirt', clip = 'try_shirt_positive_d' },
			usetime = 3500
		}
	},

	['clothing'] = {
		label = 'Clothing',
		consume = 0,
	},

	['mastercard'] = {
		label = 'Fleeca Card',
		stack = false,
		weight = 10,
		client = {
			image = 'card_bank.png'
		}
	},

	['scrapmetal'] = {
		label = 'Scrap Metal',
		weight = 80,
	},

	['advancedlockpick'] = {
		label = 'Advanced Lockpick',
		weight = 160,
		stack = true,
		close = true,
		client = {
			event = 'lockpicks:UseLockpick',
			args = true,
		},
	},

	-- TRAILHEAD ------------------------------------------------------------------

	['trail_rod_basic'] = {
		label = 'Starter Rod & Reel',
		weight = 1800,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useFishingRod' }
	},

	['trail_rod_freshwater'] = {
		label = 'Freshwater Rod & Reel',
		weight = 1650,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useFishingRod' }
	},

	['trail_rod_surf'] = {
		label = 'Surf Rod & Reel',
		weight = 2200,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useFishingRod' }
	},

	['trail_bait_worms'] = {
		label = 'Worm Bait',
		weight = 45,
		stack = true,
		close = true,
	},

	['trail_bait_shrimp'] = {
		label = 'Shrimp Bait',
		weight = 55,
		stack = true,
		close = true,
	},

	['trail_lure_spinner'] = {
		label = 'Spinner Lure',
		weight = 25,
		stack = true,
		close = true,
	},

	['trail_tackle_box'] = {
		label = 'Tackle Box',
		weight = 850,
		stack = false,
	},

	['trail_fish'] = {
		label = 'Fresh Catch',
		weight = 900,
		stack = false,
		close = false,
		consume = 0,
	},

	['trail_binoculars'] = {
		label = 'Trail Binoculars',
		weight = 620,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useBinoculars' }
	},

	['trail_field_knife'] = {
		label = 'Field Knife',
		weight = 350,
		stack = false,
		close = true,
		consume = 0,
	},

	['trail_animal_call'] = {
		label = 'Game Call',
		weight = 120,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useAnimalCall' }
	},

	['trail_hunting_pack'] = {
		label = 'Hunting Pack',
		weight = 900,
		stack = false,
	},

	['trail_game_meat'] = {
		label = 'Game Meat',
		weight = 650,
		stack = true,
		close = false,
	},

	['trail_game_hide'] = {
		label = 'Game Hide',
		weight = 1200,
		stack = false,
		close = false,
	},

	['trail_hunting_trophy'] = {
		label = 'Hunting Trophy',
		weight = 800,
		stack = false,
		close = false,
	},

	['trail_metal_detector'] = {
		label = 'Metal Detector',
		weight = 1500,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useMetalDetector' }
	},

	['trail_sand_scoop'] = {
		label = 'Sand Scoop',
		weight = 700,
		stack = false,
		close = true,
		consume = 0,
	},

	['trail_detector_battery'] = {
		label = 'Detector Battery',
		weight = 180,
		stack = true,
		close = true,
	},

	['trail_detector_find'] = {
		label = 'Detector Find',
		weight = 120,
		stack = false,
		close = false,
		consume = 0,
	},

	['trail_tent'] = {
		label = 'Two-Person Tent',
		weight = 4200,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},

	['trail_sleeping_bag'] = {
		label = 'Sleeping Bag',
		weight = 2100,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},

	['trail_camp_chair'] = {
		label = 'Camp Chair',
		weight = 2300,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},

	['trail_camp_lantern'] = {
		label = 'Camp Lantern',
		weight = 650,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},

	['trail_cooler'] = {
		label = 'Trail Cooler',
		weight = 2600,
		stack = false,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},

	['trail_campfire_kit'] = {
		label = 'Campfire Kit',
		weight = 1100,
		stack = true,
		close = true,
		consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},

	['trail_compass'] = {
		label = 'Trail Compass',
		weight = 120,
		stack = false,
	},

	['trail_flashlight'] = {
		label = 'Outdoor Flashlight',
		weight = 260,
		stack = false,
	},

	['trail_hiking_pack'] = {
		label = 'Hiking Pack',
		weight = 850,
		stack = false,
	},

	-- POLICE / TOOLS -------------------------------------------------------------

	['police_tablet'] = {
		label = 'Police MDT',
		weight = 650,
		stack = false,
		close = true,
		consume = 0,
		description = 'Department-issued secure records tablet.',
		client = {
			export = 'avid_mdt.usePoliceTablet'
		}
	},

	['small_prybar'] = {
		label = 'Small Pry Bar',
		weight = 850,
		stack = false,
		close = true,
		consume = 0,
		description = 'A compact pry tool. Small enough to hide, sturdy enough to get you in trouble.'
	},

	['wire_cutters'] = {
		label = 'Wire Cutters',
		weight = 650,
		stack = false,
		close = true,
		consume = 0,
		description = 'Insulated cutters suitable for wire and small-gauge cable.'
	},

	-- COMMON MATERIALS ------------------------------------------------------------

	['glass'] = {
		label = 'Glass',
		weight = 100,
		stack = true,
		close = false,
		description = 'Recovered glass that can be reused or processed.'
	},

	['plastic'] = {
		label = 'Plastic',
		weight = 100,
		stack = true,
		close = false,
		description = 'Assorted recyclable plastic.'
	},

	['rubber'] = {
		label = 'Rubber',
		weight = 120,
		stack = true,
		close = false,
		description = 'Recovered rubber material.'
	},

	['copper'] = {
		label = 'Copper',
		weight = 180,
		stack = true,
		close = false,
		description = 'Copper wire and scrap with resale and crafting value.'
	},

	['dirty_cloth'] = {
		label = 'Cloth',
		weight = 80,
		stack = true,
		close = true,
		description = 'A worn piece of cloth that can still be cleaned and reused.'
	},

	['electronics'] = {
		label = 'Electronics',
		weight = 120,
		stack = true,
		close = true,
		description = 'Assorted small electronic components and circuitry.'
	},

	['metalscrap'] = {
		label = 'Metal Scrap',
		weight = 200,
		stack = true,
		close = false,
		description = 'Mixed pieces of scrap metal.'
	},

	['leather'] = {
		label = 'Leather',
		weight = 150,
		stack = true,
		close = false,
		description = 'Recovered leather material.'
	},

	['steel'] = {
		label = 'Steel',
		weight = 200,
		stack = true,
		close = false,
		description = 'Recovered steel material.'
	},

	-- STOLEN GOODS ----------------------------------------------------------------

	['stolen_package'] = {
		label = 'Stolen Package',
		weight = 1000,
		stack = false,
		close = true,
		consume = 0,
		description = 'A delivery that definitely was not addressed to you.'
	},

	['stolen_phone'] = {
		label = 'Stolen Phone',
		weight = 220,
		stack = true,
		close = true,
		description = 'A locked phone with no honest explanation for how you got it.'
	},

	['stolen_wallet'] = {
		label = 'Stolen Wallet',
		weight = 100,
		stack = true,
		close = true,
		description = 'A wallet with somebody else’s life stuffed inside.'
	},

	['stolen_earbuds'] = {
		label = 'Stolen Earbuds',
		weight = 80,
		stack = true,
		close = true,
		description = 'Used wireless earbuds with questionable provenance.'
	},

	['stolen_watch'] = {
		label = 'Stolen Watch',
		weight = 120,
		stack = true,
		close = true,
		description = 'A watch that probably has an owner looking for it.'
	},

	['stolen_camera'] = {
		label = 'Stolen Camera',
		weight = 850,
		stack = true,
		close = true,
		description = 'A consumer camera snatched from an unattended vehicle.'
	},

	['stolen_tablet'] = {
		label = 'Stolen Tablet',
		weight = 650,
		stack = true,
		close = true,
		description = 'A consumer tablet with a lock screen you cannot explain.'
	},

	['stolen_laptop'] = {
		label = 'Stolen Laptop',
		weight = 1900,
		stack = true,
		close = true,
		description = 'A laptop liberated from the interior of a vehicle.'
	},

	['stolen_power_tool'] = {
		label = 'Stolen Power Tool',
		weight = 1800,
		stack = true,
		close = true,
		description = 'A jobsite power tool with somebody else’s initials on it.'
	},

	['stolen_toolbox'] = {
		label = 'Stolen Toolbox',
		weight = 3200,
		stack = false,
		close = true,
		description = 'A heavy toolbox taken from a worksite.'
	},

	['stolen_goods'] = {
		label = 'Stolen Property',
		weight = 250,
		stack = false,
		close = false,
		description = 'Property that probably has an owner looking for it.'
	},

	-- HOUSING / CRAFTING ----------------------------------------------------------

	['utility_bench_kit'] = {
		label = 'Workbench Kit',
		weight = 12500,
		stack = false,
		close = true,
		consume = 0,
		description = 'A boxed workbench ready to assemble inside an apartment or property.',
		client = {
			export = 'qbx_properties.placeUtilityBench',
		},
	},

	['avid_machined_parts'] = {
		label = 'Machined Parts',
		weight = 180,
		stack = true,
		close = true,
		description = 'Precision workshop components used in advanced fabrication.',
	},

	['avid_polymer_parts'] = {
		label = 'Polymer Components',
		weight = 100,
		stack = true,
		close = true,
		description = 'Molded workshop components used in advanced fabrication.',
	},

	['avid_precision_spring'] = {
		label = 'Precision Spring Set',
		weight = 80,
		stack = true,
		close = true,
		description = 'A tuned mechanical component set used by advanced workshop recipes.',
	},

	['blueprint_sns_pistol'] = {
		label = 'SNS Pistol Schematic',
		weight = 25,
		stack = false,
		close = true,
		description = 'A reusable schematic required to assemble an SNS Pistol at a Weapons Workbench.',
	},

	['blueprint_pistol'] = {
		label = 'Pistol Schematic',
		weight = 25,
		stack = false,
		close = true,
		description = 'A reusable schematic required to assemble a Pistol at a Weapons Workbench.',
	},

	['blueprint_vintage_pistol'] = {
		label = 'Vintage Pistol Schematic',
		weight = 25,
		stack = false,
		close = true,
		description = 'A reusable schematic required to assemble a Vintage Pistol at a Weapons Workbench.',
	},

	['blueprint_machine_pistol'] = {
		label = 'Machine Pistol Schematic',
		weight = 25,
		stack = false,
		close = true,
		description = 'A reusable schematic required to assemble a Machine Pistol at a Weapons Workbench.',
	},

	['burglary_document'] = {
		label = 'Stolen Documents',
		weight = 50,
		stack = false,
		close = true,
		consume = 0,
		description = 'Paperwork that may contain useful information.',
		client = {
			export = 'avid_underworld.useBurglaryDocument'
		},
	},

}

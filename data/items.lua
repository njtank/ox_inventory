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

	['sprunk'] = {
		label = 'Sprunk',
		weight = 350,
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_can_01`, pos = vec3(0.01, 0.01, 0.06), rot = vec3(5.0, 5.0, -180.5) },
			usetime = 2500,
			notification = 'You quenched your thirst with a sprunk'
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
		client = {
			status = { thirst = 200000 },
			anim = { dict = 'mp_player_intdrink', clip = 'loop_bottle' },
			prop = { model = `prop_ld_flow_bottle`, pos = vec3(0.03, 0.03, 0.02), rot = vec3(0.0, 0.0, -1.5) },
			usetime = 2500,
			cancel = true,
			notification = 'You drank some refreshing water'
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

	-- Trailhead outdoors system
	['trail_rod_basic'] = {
		label = 'Starter Rod & Reel', weight = 1800, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useFishingRod' }
	},
	['trail_rod_freshwater'] = {
		label = 'Freshwater Rod & Reel', weight = 1650, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useFishingRod' }
	},
	['trail_rod_surf'] = {
		label = 'Surf Rod & Reel', weight = 2200, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useFishingRod' }
	},
	['trail_bait_worms'] = { label = 'Worm Bait', weight = 45, stack = true, close = true },
	['trail_bait_shrimp'] = { label = 'Shrimp Bait', weight = 55, stack = true, close = true },
	['trail_lure_spinner'] = { label = 'Spinner Lure', weight = 25, stack = true, close = true },
	['trail_tackle_box'] = { label = 'Tackle Box', weight = 850, stack = false },
	['trail_fish'] = { label = 'Fresh Catch', weight = 900, stack = false, close = false, consume = 0 },

	['trail_binoculars'] = {
		label = 'Trail Binoculars', weight = 620, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useBinoculars' }
	},
	['trail_field_knife'] = { label = 'Field Knife', weight = 350, stack = false, close = true, consume = 0 },
	['trail_animal_call'] = {
		label = 'Game Call', weight = 120, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useAnimalCall' }
	},
	['trail_hunting_pack'] = { label = 'Hunting Pack', weight = 900, stack = false },
	['trail_game_meat'] = { label = 'Game Meat', weight = 650, stack = true, close = false },
	['trail_game_hide'] = { label = 'Game Hide', weight = 1200, stack = false, close = false },
	['trail_hunting_trophy'] = { label = 'Hunting Trophy', weight = 800, stack = false, close = false },

	['trail_metal_detector'] = {
		label = 'Metal Detector', weight = 1500, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useMetalDetector' }
	},
	['trail_sand_scoop'] = { label = 'Sand Scoop', weight = 700, stack = false, close = true, consume = 0 },
	['trail_detector_battery'] = { label = 'Detector Battery', weight = 180, stack = true, close = true },
	['trail_detector_find'] = { label = 'Detector Find', weight = 120, stack = false, close = false, consume = 0 },

	['trail_tent'] = {
		label = 'Two-Person Tent', weight = 4200, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},
	['trail_sleeping_bag'] = {
		label = 'Sleeping Bag', weight = 2100, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},
	['trail_camp_chair'] = {
		label = 'Camp Chair', weight = 2300, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},
	['trail_camp_lantern'] = {
		label = 'Camp Lantern', weight = 650, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},
	['trail_cooler'] = {
		label = 'Trail Cooler', weight = 2600, stack = false, close = true, consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},
	['trail_campfire_kit'] = {
		label = 'Campfire Kit', weight = 1100, stack = true, close = true, consume = 0,
		client = { export = 'avid-trailhead.useCampGear' }
	},

	['trail_compass'] = { label = 'Trail Compass', weight = 120, stack = false },
	['trail_flashlight'] = { label = 'Outdoor Flashlight', weight = 260, stack = false },
	['trail_hiking_pack'] = { label = 'Hiking Pack', weight = 850, stack = false },
}
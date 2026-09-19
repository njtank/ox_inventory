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
}

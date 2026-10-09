return {
    version = 1,

    playerGrid = { cols = 8, rows = 6 },

    containerLayouts = {
        [30] = { cols = 6, rows = 5 },
        [42] = { cols = 7, rows = 6 },
        [56] = { cols = 8, rows = 7 },
    },

    defaultItemSize = { w = 1, h = 1 },

    externalStorage = {
        supported = {
            stash = true,
            policeevidence = true,
            trunk = true,
            glovebox = true,
            container = true,
            dumpster = true,
            temp = true,
        },
        columns = {
            glovebox = 5,
            trunk = 8,
            stash = 8,
            policeevidence = 10,
            container = 7,
            dumpster = 6,
            temp = 8,
        },
        defaultColumns = 8,
    },

    itemSizes = {
        phone = { w = 1, h = 1 },
        burnerphone = { w = 1, h = 1 },
        radio = { w = 1, h = 1 },
        water = { w = 1, h = 1 },
        coffee = { w = 1, h = 1 },
        sandwich = { w = 1, h = 1 },
        donut = { w = 1, h = 1 },
        chocolate_bar = { w = 1, h = 1 },
        chips = { w = 1, h = 1 },
        energy_drink = { w = 1, h = 1 },
        cigarettes = { w = 1, h = 1 },
        burger = { w = 1, h = 1 },
        bandage = { w = 1, h = 1 },
        lockpick = { w = 1, h = 1 },
        advancedlockpick = { w = 1, h = 1 },
        repairkit = { w = 2, h = 2 },
        advancedrepairkit = { w = 2, h = 2 },
        toolkit = { w = 2, h = 2 },
        camera = { w = 2, h = 2 },
        binoculars = { w = 2, h = 2 },
        armour_plate = { w = 2, h = 2 },
        light_armour = { w = 2, h = 3 },
        heavy_armour = { w = 3, h = 3 },
        backpack_small = { w = 2, h = 2 },
        backpack_medium = { w = 2, h = 3 },
        backpack_large = { w = 3, h = 3 },

        WEAPON_PISTOL = { w = 2, h = 2 },
        WEAPON_COMBATPISTOL = { w = 2, h = 2 },
        WEAPON_APPISTOL = { w = 2, h = 2 },
        WEAPON_PISTOL50 = { w = 2, h = 2 },
        WEAPON_SNSPISTOL = { w = 2, h = 2 },
        WEAPON_HEAVYPISTOL = { w = 2, h = 2 },

        WEAPON_MICROSMG = { w = 2, h = 4 },
        WEAPON_SMG = { w = 2, h = 4 },
        WEAPON_CARBINERIFLE = { w = 2, h = 5 },
        WEAPON_CARBINERIFLE_MK2 = { w = 2, h = 5 },
        WEAPON_ASSAULTRIFLE = { w = 2, h = 5 },
        WEAPON_PUMPSHOTGUN = { w = 2, h = 6 },

        WEAPON_KNIFE = { w = 1, h = 3 },
        WEAPON_BAT = { w = 1, h = 4 },
        WEAPON_CROWBAR = { w = 1, h = 4 },
        WEAPON_HAMMER = { w = 1, h = 3 },
    },

    equipment = {
        phone = { label = 'Phone', items = { phone = true, burnerphone = true } },
        radio = { label = 'Radio', items = { radio = true } },
        backpack = { label = 'Bag', items = {
            backpack_small = true,
            backpack_medium = true,
            backpack_large = true,
        }},
        armor = { label = 'Armor', items = {
            armour = true,
            light_armour = true,
            heavy_armour = true,
        }},
        secondary = { label = 'Secondary', items = {
            WEAPON_PISTOL = true,
            WEAPON_COMBATPISTOL = true,
            WEAPON_APPISTOL = true,
            WEAPON_PISTOL50 = true,
            WEAPON_SNSPISTOL = true,
            WEAPON_HEAVYPISTOL = true,
        }},
        melee = { label = 'Melee', items = {
            WEAPON_KNIFE = true,
            WEAPON_BAT = true,
            WEAPON_CROWBAR = true,
            WEAPON_HAMMER = true,
        }},
        primary = { label = 'Primary', weaponFallback = true },
    },

    shops = {
        targetResource = 'avid_target',
            basketLimit = 12,
            checkoutDistance = 3.0,
        
            pickupAnim = {
                dict = 'mp_common',
                clip = 'givetake1_a',
                duration = 700,
                flag = 49,
            },
        
            stores = {
                strawberry_247 = {
                    label = '24/7 Strawberry',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(25.34, -1347.18, 28.50, 273.65),
                        target = {
                            coords = vec3(25.584, -1347.158, 29.722),
                            size = vec3(0.90, 0.90, 1.15),
                            rotation = 273.65,
                        },
                    },
                    shelves = {
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(26.256, -1346.933, 29.247),
                            size = vec3(0.72, 0.62, 0.72),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(28.576, -1345.963, 29.489),
                            size = vec3(1.05, 0.70, 0.72),
                            rotation = 0.0,
                            items = {
                                { name = 'noodle_cup', label = 'Noodle Cup', price = 8 },
                                { name = 'veggie_wrap', label = 'Veggie Wrap', price = 9 },
                                { name = 'hotdog_plain', label = 'Hotdog', price = 7 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(31.530, -1341.802, 29.719),
                            size = vec3(1.25, 0.78, 0.78),
                            rotation = 0.0,
                            items = {
                                { name = 'apple_juice', label = 'Apple Juice', price = 4 },
                                { name = 'ecola', label = 'eCola', price = 4 },
                                { name = 'ecola_light', label = 'eCola Light', price = 4 },
                                { name = 'junk_drink', label = 'Junk Energy Drink', price = 5 },
                                { name = 'orangotang', label = 'Orang-O-Tang', price = 5 },
                                { name = 'raine', label = 'Raine', price = 4 },
                                { name = 'sprunk', label = 'Sprunk', price = 4 },
                                { name = 'sprunk_light', label = 'Sprunk Light', price = 4 },
                            },
                        },
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(23.963, -1345.335, 30.182),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                    },
                },
        
                david_ltd = {
                    label = 'David LTD',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(-47.04, -1758.47, 28.42, 48.13),
                        target = {
                            coords = vec3(-47.04, -1758.47, 29.42),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 48.13,
                        },
                    },
                    shelves = {
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(-47.481, -1757.438, 29.070),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(-49.071, -1754.965, 29.387),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'noodle_cup', label = 'Noodle Cup', price = 8 },
                                { name = 'veggie_wrap', label = 'Veggie Wrap', price = 9 },
                                { name = 'hotdog_plain', label = 'Hotdog', price = 7 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(-54.689, -1748.206, 29.674),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'apple_juice', label = 'Apple Juice', price = 4 },
                                { name = 'ecola', label = 'eCola', price = 4 },
                                { name = 'ecola_light', label = 'eCola Light', price = 4 },
                                { name = 'junk_drink', label = 'Junk Energy Drink', price = 5 },
                                { name = 'orangotang', label = 'Orang-O-Tang', price = 5 },
                                { name = 'raine', label = 'Raine', price = 4 },
                                { name = 'sprunk', label = 'Sprunk', price = 4 },
                                { name = 'sprunk_light', label = 'Sprunk Light', price = 4 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(-56.678, -1750.575, 29.698),
                            size = vec3(1.08, 0.80, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                    },
                },
        
                little_seoul_ltd = {
                    label = 'Little Seoul LTD',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(-706.14, -914.18, 18.22, 84.27),
                        target = {
                            coords = vec3(-706.14, -914.18, 19.22),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 84.27,
                        },
                    },
                    shelves = {
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(-706.861, -913.984, 18.591),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(-709.819, -912.829, 19.139),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'noodle_cup', label = 'Noodle Cup', price = 8 },
                                { name = 'veggie_wrap', label = 'Veggie Wrap', price = 9 },
                                { name = 'hotdog_plain', label = 'Hotdog', price = 7 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(-718.460, -911.677, 19.485),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'apple_juice', label = 'Apple Juice', price = 4 },
                                { name = 'ecola', label = 'eCola', price = 4 },
                                { name = 'ecola_light', label = 'eCola Light', price = 4 },
                                { name = 'junk_drink', label = 'Junk Energy Drink', price = 5 },
                                { name = 'orangotang', label = 'Orang-O-Tang', price = 5 },
                                { name = 'raine', label = 'Raine', price = 4 },
                                { name = 'sprunk', label = 'Sprunk', price = 4 },
                                { name = 'sprunk_light', label = 'Sprunk Light', price = 4 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(-718.460, -914.414, 19.519),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                    },
                },
        
                downtown_vinewood_247 = {
                    label = '24/7 Downtown Vinewood',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(373.37, 326.51, 102.58, 251.73),
                        target = {
                            coords = vec3(373.37, 326.51, 103.58),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 251.73,
                        },
                    },
                    shelves = {
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(374.375, 326.299, 102.928),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(379.517, 327.417, 103.519),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'noodle_cup', label = 'Noodle Cup', price = 8 },
                                { name = 'veggie_wrap', label = 'Veggie Wrap', price = 9 },
                                { name = 'hotdog_plain', label = 'Hotdog', price = 7 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(380.788, 330.066, 103.816),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'apple_juice', label = 'Apple Juice', price = 4 },
                                { name = 'ecola', label = 'eCola', price = 4 },
                                { name = 'ecola_light', label = 'eCola Light', price = 4 },
                                { name = 'junk_drink', label = 'Junk Energy Drink', price = 5 },
                                { name = 'orangotang', label = 'Orang-O-Tang', price = 5 },
                                { name = 'raine', label = 'Raine', price = 4 },
                                { name = 'sprunk', label = 'Sprunk', price = 4 },
                                { name = 'sprunk_light', label = 'Sprunk Light', price = 4 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(379.265, 330.449, 103.960),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                    },
                },
                liquor_vespucci_canals = {
                    label = 'Liquor Store: Vespucci Canals',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(-1222.34, -908.67, 11.33, 37.74),
                        target = {
                            coords = vec3(-1222.34, -908.67, 12.33),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 37.74,
                        },
                    },
                    shelves = {
                        beer = {
                            label = 'Beer',
                            coords = vec3(-1226.658, -907.833, 12.562),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(-1222.806, -907.561, 12.109),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(-1223.465, -908.322, 12.412),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                    },
                },

                liquor_morning_wood = {
                    label = 'Liquor Store Morning Wood',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(-1485.86, -378.37, 39.16, 133.61),
                        target = {
                            coords = vec3(-1485.86, -378.37, 40.16),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 133.61,
                        },
                    },
                    shelves = {
                        beer = {
                            label = 'Beer',
                            coords = vec3(-1485.770, -382.646, 40.417),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(-1487.020, -378.799, 39.853),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(-1485.959, -379.488, 40.143),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                    },
                },

                liquor_murrieta_heights = {
                    label = 'Liquor Store Murrieta Heights',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(1134.11, -981.96, 45.42, 273.96),
                        target = {
                            coords = vec3(1134.11, -981.96, 46.42),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 273.96,
                        },
                    },
                    shelves = {
                        beer = {
                            label = 'Beer',
                            coords = vec3(1136.643, -978.476, 46.757),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(1135.286, -982.270, 46.152),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(1134.863, -981.138, 46.449),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                    },
                },

                liquor_grand_senora = {
                    label = 'Liquor Store Grand Senora',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(1166.56, 2710.79, 37.16, 172.96),
                        target = {
                            coords = vec3(1166.56, 2710.79, 38.16),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 172.96,
                        },
                    },
                    shelves = {
                        beer = {
                            label = 'Beer',
                            coords = vec3(1169.557, 2707.867, 38.429),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(1166.128, 2709.718, 37.948),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(1167.189, 2709.983, 38.169),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                    },
                },

                liquor_sandy_shores = {
                    label = 'Liquor Store Sandy Shores',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(1392.5, 3606.32, 33.98, 196.94),
                        target = {
                            coords = vec3(1392.5, 3606.32, 34.98),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 196.94,
                        },
                    },
                    shelves = {
                        beer = {
                            label = 'Beer',
                            coords = vec3(1398.779, 3607.191, 35.153),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(1391.925, 3605.153, 34.923),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(1394.063, 3605.998, 35.041),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                    },
                },

                tataviam_247 = {
                    label = '24/7 Tataviam Mountain',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(2557.06, 381.72, 107.64, 6.02),
                        target = {
                            coords = vec3(2557.06, 381.72, 108.64),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 6.02,
                        },
                    },
                    shelves = {
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(2555.197, 380.395, 109.370),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(2557.050, 382.617, 108.295),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(2554.964, 387.463, 108.577),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'noodle_cup', label = 'Noodle Cup', price = 8 },
                                { name = 'veggie_wrap', label = 'Veggie Wrap', price = 9 },
                                { name = 'hotdog_plain', label = 'Hotdog', price = 7 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(2551.958, 386.693, 108.887),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(2552.012, 388.050, 108.908),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'apple_juice', label = 'Apple Juice', price = 4 },
                                { name = 'ecola', label = 'eCola', price = 4 },
                                { name = 'ecola_light', label = 'eCola Light', price = 4 },
                                { name = 'junk_drink', label = 'Junk Energy Drink', price = 5 },
                                { name = 'orangotang', label = 'Orang-O-Tang', price = 5 },
                                { name = 'raine', label = 'Raine', price = 4 },
                                { name = 'sprunk', label = 'Sprunk', price = 4 },
                                { name = 'sprunk_light', label = 'Sprunk Light', price = 4 },
                            },
                        },
                    },
                },

                route_68_247 = {
                    label = '24/7 Route 68',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(548.32, 2671.07, 41.16, 98.62),
                        target = {
                            coords = vec3(548.32, 2671.07, 42.16),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 98.62,
                        },
                    },
                    shelves = {
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(549.771, 2669.897, 42.954),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(547.331, 2670.860, 41.814),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(542.924, 2667.962, 42.103),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'noodle_cup', label = 'Noodle Cup', price = 8 },
                                { name = 'veggie_wrap', label = 'Veggie Wrap', price = 9 },
                                { name = 'hotdog_plain', label = 'Hotdog', price = 7 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(544.165, 2665.151, 42.416),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(542.705, 2664.958, 42.486),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'apple_juice', label = 'Apple Juice', price = 4 },
                                { name = 'ecola', label = 'eCola', price = 4 },
                                { name = 'ecola_light', label = 'eCola Light', price = 4 },
                                { name = 'junk_drink', label = 'Junk Energy Drink', price = 5 },
                                { name = 'orangotang', label = 'Orang-O-Tang', price = 5 },
                                { name = 'raine', label = 'Raine', price = 4 },
                                { name = 'sprunk', label = 'Sprunk', price = 4 },
                                { name = 'sprunk_light', label = 'Sprunk Light', price = 4 },
                            },
                        },
                    },
                },

                grapeseed_ltd = {
                    label = 'LTD Grapeseed',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(1697.45, 4923.36, 41.06, 333.94),
                        target = {
                            coords = vec3(1697.45, 4923.36, 42.06),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 333.94,
                        },
                    },
                    shelves = {
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(1697.104, 4924.513, 42.161),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(1697.677, 4924.265, 41.758),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(1700.903, 4925.098, 41.966),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'noodle_cup', label = 'Noodle Cup', price = 8 },
                                { name = 'veggie_wrap', label = 'Veggie Wrap', price = 9 },
                                { name = 'hotdog_plain', label = 'Hotdog', price = 7 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(1704.628, 4933.376, 42.306),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(1707.268, 4931.528, 42.362),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'apple_juice', label = 'Apple Juice', price = 4 },
                                { name = 'ecola', label = 'eCola', price = 4 },
                                { name = 'ecola_light', label = 'eCola Light', price = 4 },
                                { name = 'junk_drink', label = 'Junk Energy Drink', price = 5 },
                                { name = 'orangotang', label = 'Orang-O-Tang', price = 5 },
                                { name = 'raine', label = 'Raine', price = 4 },
                                { name = 'sprunk', label = 'Sprunk', price = 4 },
                                { name = 'sprunk_light', label = 'Sprunk Light', price = 4 },
                            },
                        },
                    },
                },

                mount_chiliad_247 = {
                    label = '24/7 Mount Chiliad',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(1728.66, 6414.87, 34.04, 248.84),
                        target = {
                            coords = vec3(1728.66, 6414.87, 35.04),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 248.84,
                        },
                    },
                    shelves = {
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(1728.030, 6416.724, 35.860),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(1729.557, 6414.640, 34.713),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(1734.789, 6414.381, 35.009),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'noodle_cup', label = 'Noodle Cup', price = 8 },
                                { name = 'veggie_wrap', label = 'Veggie Wrap', price = 9 },
                                { name = 'hotdog_plain', label = 'Hotdog', price = 7 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(1735.471, 6417.463, 35.478),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(1736.694, 6416.857, 35.459),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'apple_juice', label = 'Apple Juice', price = 4 },
                                { name = 'ecola', label = 'eCola', price = 4 },
                                { name = 'ecola_light', label = 'eCola Light', price = 4 },
                                { name = 'junk_drink', label = 'Junk Energy Drink', price = 5 },
                                { name = 'orangotang', label = 'Orang-O-Tang', price = 5 },
                                { name = 'raine', label = 'Raine', price = 4 },
                                { name = 'sprunk', label = 'Sprunk', price = 4 },
                                { name = 'sprunk_light', label = 'Sprunk Light', price = 4 },
                            },
                        },
                    },
                },

                chumash_247 = {
                    label = '24/7 Chumash',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(-3242.44, 1000.87, 11.85, 352.84),
                        target = {
                            coords = vec3(-3242.44, 1000.87, 12.85),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 352.84,
                        },
                    },
                    shelves = {
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(-3244.104, 999.690, 13.559),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(-3242.662, 1001.868, 12.576),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(-3244.313, 1006.811, 12.813),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'noodle_cup', label = 'Noodle Cup', price = 8 },
                                { name = 'veggie_wrap', label = 'Veggie Wrap', price = 9 },
                                { name = 'hotdog_plain', label = 'Hotdog', price = 7 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(-3247.394, 1006.265, 13.290),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(-3247.277, 1007.623, 13.286),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'apple_juice', label = 'Apple Juice', price = 4 },
                                { name = 'ecola', label = 'eCola', price = 4 },
                                { name = 'ecola_light', label = 'eCola Light', price = 4 },
                                { name = 'junk_drink', label = 'Junk Energy Drink', price = 5 },
                                { name = 'orangotang', label = 'Orang-O-Tang', price = 5 },
                                { name = 'raine', label = 'Raine', price = 4 },
                                { name = 'sprunk', label = 'Sprunk', price = 4 },
                                { name = 'sprunk_light', label = 'Sprunk Light', price = 4 },
                            },
                        },
                    },
                },

                chumash_247_2 = {
                    label = '24/7 Chumash 2',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(-3039.5, 585.25, 6.92, 18.97),
                        target = {
                            coords = vec3(-3039.5, 585.25, 7.92),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 18.97,
                        },
                    },
                    shelves = {
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(-3040.351, 583.537, 8.663),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(-3040.031, 586.048, 7.638),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(-3043.433, 589.987, 7.882),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'noodle_cup', label = 'Noodle Cup', price = 8 },
                                { name = 'veggie_wrap', label = 'Veggie Wrap', price = 9 },
                                { name = 'hotdog_plain', label = 'Hotdog', price = 7 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(-3046.075, 588.281, 8.352),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(-3046.502, 589.697, 8.344),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'apple_juice', label = 'Apple Juice', price = 4 },
                                { name = 'ecola', label = 'eCola', price = 4 },
                                { name = 'ecola_light', label = 'eCola Light', price = 4 },
                                { name = 'junk_drink', label = 'Junk Energy Drink', price = 5 },
                                { name = 'orangotang', label = 'Orang-O-Tang', price = 5 },
                                { name = 'raine', label = 'Raine', price = 4 },
                                { name = 'sprunk', label = 'Sprunk', price = 4 },
                                { name = 'sprunk_light', label = 'Sprunk Light', price = 4 },
                            },
                        },
                    },
                },

                liquor_chumash = {
                    label = 'Liquor Store Chumash',
                    clerk = {
                        model = 'mp_m_shopkeep_01',
                        coords = vec4(-2966.42, 390.29, 14.04, 91.86),
                        target = {
                            coords = vec3(-2966.42, 390.29, 15.04),
                            size = vec3(0.95, 0.95, 1.20),
                            rotation = 91.86,
                        },
                    },
                    shelves = {
                        beer = {
                            label = 'Beer',
                            coords = vec3(-2969.599, 387.460, 15.294),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'ambeer', label = 'A.M. Beer', price = 7 },
                                { name = 'dusche_beer', label = 'Dusche Gold', price = 8 },
                                { name = 'logger_beer', label = 'Logger Beer', price = 7 },
                                { name = 'pisswasser', label = 'Pißwasser', price = 6 },
                            },
                        },
                        snacks = {
                            label = 'Snacks',
                            coords = vec3(-2967.501, 391.048, 14.812),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                                { name = 'slickers', label = 'Slickers', price = 4 },
                                { name = 'twerks', label = 'Twerks', price = 4 },
                                { name = 'phat_chips', label = 'Phat Chips', price = 5 },
                                { name = 'egochaser_bar', label = 'EgoChaser Energy Bar', price = 6 },
                            },
                        },
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(-2967.319, 389.724, 15.032),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'redwood_cigarettes', label = 'Redwood Cigarettes', price = 20 },
                                { name = 'cigs_69', label = '69 Brand Cigarettes', price = 18 },
                                { name = 'homies_cigars', label = 'Homies Cigars', price = 28 },
                            },
                        },
                    },
                },

            },
    },

}

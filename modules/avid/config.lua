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
                        candies = {
                            label = 'Candies',
                            coords = vec3(26.256, -1346.933, 29.247),
                            size = vec3(0.72, 0.62, 0.72),
                            rotation = 0.0,
                            items = {
                                { name = 'chocolate_bar', label = 'Candy Bar', price = 4 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(28.576, -1345.963, 29.489),
                            size = vec3(1.05, 0.70, 0.72),
                            rotation = 0.0,
                            items = {
                                { name = 'sandwich', label = 'Deli Sandwich', price = 7 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(31.530, -1341.802, 29.719),
                            size = vec3(1.25, 0.78, 0.78),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                            },
                        },
                        cigarettes = {
                            label = 'Cigarettes',
                            coords = vec3(23.963, -1345.335, 30.182),
                            size = vec3(0.92, 0.58, 0.68),
                            rotation = 0.0,
                            items = {
                                { name = 'cigarettes', label = 'Cigarettes', price = 18 },
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
                        candies = {
                            label = 'Candies',
                            coords = vec3(-47.481, -1757.438, 29.070),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'chocolate_bar', label = 'Candy Bar', price = 4 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(-49.071, -1754.965, 29.387),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'sandwich', label = 'Deli Sandwich', price = 7 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(-54.689, -1748.206, 29.674),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(-56.678, -1750.575, 29.698),
                            size = vec3(1.08, 0.80, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'beer', label = 'Beer', price = 6 },
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
                        candies = {
                            label = 'Candies',
                            coords = vec3(-706.861, -913.984, 18.591),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'chocolate_bar', label = 'Candy Bar', price = 4 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(-709.819, -912.829, 19.139),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'sandwich', label = 'Deli Sandwich', price = 7 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(-718.460, -911.677, 19.485),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(-718.460, -914.414, 19.519),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'beer', label = 'Beer', price = 6 },
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
                        candies = {
                            label = 'Candies',
                            coords = vec3(374.375, 326.299, 102.928),
                            size = vec3(0.82, 0.72, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'chocolate_bar', label = 'Candy Bar', price = 4 },
                            },
                        },
                        food = {
                            label = 'Prepared Food',
                            coords = vec3(379.517, 327.417, 103.519),
                            size = vec3(1.05, 0.76, 0.82),
                            rotation = 0.0,
                            items = {
                                { name = 'sandwich', label = 'Deli Sandwich', price = 7 },
                            },
                        },
                        drinks = {
                            label = 'Cold Drinks',
                            coords = vec3(380.788, 330.066, 103.816),
                            size = vec3(1.20, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'water', label = 'Water', price = 3 },
                            },
                        },
                        beer = {
                            label = 'Beer',
                            coords = vec3(379.265, 330.449, 103.960),
                            size = vec3(1.10, 0.82, 0.88),
                            rotation = 0.0,
                            items = {
                                { name = 'beer', label = 'Beer', price = 6 },
                            },
                        },
                    },
                },
            },
    },

}

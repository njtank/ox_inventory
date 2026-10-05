return {
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
}

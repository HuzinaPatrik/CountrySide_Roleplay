handlingData = {
    --[[
    [modelid] = {
        [property] = value,

        ["tuningFlags"] = {
            ["tuningName"] = {
                [level] = {
                    --additional flags
                    [property] = +value,
                },

                [maxLevel] = maxLevel,
            },
        },
    }
    ]]
	-- BIKE
	[510] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 100,
		["engineAcceleration"] = 5,
		["engineInertia"] = 10,
		["driveType"] = "awd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.01,
		
		--BodySettings
		["mass"] = 100,
		["turnMass"] = 60,
		["dragCoeff"] = 0,
		["centerofmass"] = {0, 0.5, -0.09},
		["percentSubmerged"] = 103,
		["animGroup"] = 10,
		["seatOffsetDistance"] = 0,
		
		--WheelSettings
		["tractionMultiplier"] = 1.6,
		["tractionLoss"] = 0.9,
		["tractionBias"] = 0.48,
		["brakeDeceleration"] = 19,
        ["brakeBias"] = 0.5,
		["suspensionForceLevel"] = 0.85,
		["suspensionDamping"] = 0.15,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.2,
		["suspensionLowerLimit"] = -0.1,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x41000000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x2,
		
		--Other Settings
	},
	
	-- BIKE --

	-- CIVILIAN 
	[401] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 160,
		["engineAcceleration"] = 6,
		["engineInertia"] = 15,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1300,
		["turnMass"] = 2200,
		["dragCoeff"] = 1.7,
		["centerofmass"] = {0, 0.0, 0},
		["percentSubmerged"] = 70,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.26,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 1,
		["tractionBias"] = 0.52,
		["brakeDeceleration"] = 9,
        ["brakeBias"] = 0.8,
		["suspensionForceLevel"] = 1.3,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.3,
		["suspensionLowerLimit"] = -0.01,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x2001,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x1,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},
	
	[402] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 200,
		["engineAcceleration"] = 11.2,
		["engineInertia"] = 5,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1500,
		["turnMass"] = 4000,
		["dragCoeff"] = 2,
		["centerofmass"] = {0, 0.0, -0.1},
		["percentSubmerged"] = 85,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.25,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 0.9,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 11,
        ["brakeBias"] = 0.45,
		["suspensionForceLevel"] = 1.2,
		["suspensionDamping"] = 0.5,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.28,
		["suspensionLowerLimit"] = -0.24,
		["suspensionAntiDiveMultiplier"] = 0.4,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x2800,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x10200000,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[404] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 170,
		["engineAcceleration"] = 8,
		["engineInertia"] = 10,
		["driveType"] = "fwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1200,
		["turnMass"] = 3000,
		["dragCoeff"] = 2.5,
		["centerofmass"] = {0, 0.0, 0},
		["percentSubmerged"] = 70,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.2,
		
		--WheelSettings
		["tractionMultiplier"] = 0.8,
		["tractionLoss"] = 1.0,
		["tractionBias"] = 0.48,
		["brakeDeceleration"] = 8,
        ["brakeBias"] = 1,
		["suspensionForceLevel"] = 1.4,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.3,
		["suspensionLowerLimit"] = -0.17,
		["suspensionAntiDiveMultiplier"] = 0.0,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x2020,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x1,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[413] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 160,
		["engineAcceleration"] = 6,
		["engineInertia"] = 25,
		["driveType"] = "rwd",
		["engineType"] = "diesel",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 2600,
		["turnMass"] = 8666.7,
		["dragCoeff"] = 3,
		["centerofmass"] = {0, 0.0, -0.25},
		["percentSubmerged"] = 80,
		["animGroup"] = 13,
		["seatOffsetDistance"] = 0.2,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 1.0,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 6,
        ["brakeBias"] = 0.8,
		["suspensionForceLevel"] = 2.6,
		["suspensionDamping"] = 0.7,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.5,
		["suspensionLowerLimit"] = -0.1,
		["suspensionAntiDiveMultiplier"] = 0.0,
		["suspensionFrontRearBias"] = 0.25,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x4001,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x1,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[418] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 150,
		["engineAcceleration"] = 6,
		["engineInertia"] = 15,
		["driveType"] = "rwd",
		["engineType"] = "diesel",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 2000,
		["turnMass"] = 5848.3,
		["dragCoeff"] = 2.8,
		["centerofmass"] = {0, 0.2, -0.1},
		["percentSubmerged"] = 85,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.2,
		
		--WheelSettings
		["tractionMultiplier"] = 0.6,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 5.5,
        ["brakeBias"] = 0.6,
		["suspensionForceLevel"] = 1.4,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.35,
		["suspensionLowerLimit"] = -0.15,
		["suspensionAntiDiveMultiplier"] = 0.0,
		["suspensionFrontRearBias"] = 0.55,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x20,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x0,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[422] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 165,
		["engineAcceleration"] = 8,
		["engineInertia"] = 15,
		["driveType"] = "rwd",
		["engineType"] = "diesel",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1700,
		["turnMass"] = 4000,
		["dragCoeff"] = 2.8,
		["centerofmass"] = {0, 0.05, -0.2},
		["percentSubmerged"] = 75,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.26,
		
		--WheelSettings
		["tractionMultiplier"] = 0.65,
		["tractionLoss"] = 0.85,
		["tractionBias"] = 0.57,
		["brakeDeceleration"] = 8.5,
        ["brakeBias"] = 0.5,
		["suspensionForceLevel"] = 1.5,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 5,
		["suspensionUpperLimit"] = 0.35,
		["suspensionLowerLimit"] = -0.18,
		["suspensionAntiDiveMultiplier"] = 0.0,
		["suspensionFrontRearBias"] = 0.4,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x104004,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[429] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 220,
		["engineAcceleration"] = 13.5,
		["engineInertia"] = 10,
		["driveType"] = "awd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1400,
		["turnMass"] = 3000,
		["dragCoeff"] = 2,
		["centerofmass"] = {0, 0.0, -0.0},
		["percentSubmerged"] = 70,
		["animGroup"] = 1,
		["seatOffsetDistance"] = 0.15,
		
		--WheelSettings
		["tractionMultiplier"] = 0.8,
		["tractionLoss"] = 1,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 10,
        ["brakeBias"] = 0.7,
		["suspensionForceLevel"] = 1.6,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 5,
		["suspensionUpperLimit"] = 0.1,
		["suspensionLowerLimit"] = -0.14,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x2004,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x200000,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[436] = {
		--Engine Settings
		["numberOfGears"] = 4,
		["maxVelocity"] = 160,
		["engineAcceleration"] = 7.2,
		["engineInertia"] = 7,
		["driveType"] = "fwd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1400,
		["turnMass"] = 3000,
		["dragCoeff"] = 2.6,
		["centerofmass"] = {0, 0.3, -0.1},
		["percentSubmerged"] = 70,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.21,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.45,
		["brakeDeceleration"] = 8,
        ["brakeBias"] = 0.65,
		["suspensionForceLevel"] = 1.1,
		["suspensionDamping"] = 0.08,
		["suspensionHighSpeedDamping"] = 2,
		["suspensionUpperLimit"] = 0.31,
		["suspensionLowerLimit"] = -0.18,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.55,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x2000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x0,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

    [431] = {
        ["maxVelocity"] = 80,
        ["dragCoeff"] = 5,
    },

    [437] = {
        ["maxVelocity"] = 80,
        ["dragCoeff"] = 6.9,
    },
	
	[456] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 160,
		["engineAcceleration"] = 5.6,
		["engineInertia"] = 40,
		["driveType"] = "rwd",
		["engineType"] = "diesel",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 4500,
		["turnMass"] = 18000,
		["dragCoeff"] = 3,
		["centerofmass"] = {0, -0.8, -0.0},
		["percentSubmerged"] = 80,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.35,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 0.7,
		["tractionBias"] = 0.48,
		["brakeDeceleration"] = 5,
        ["brakeBias"] = 0.8,
		["suspensionForceLevel"] = 1.8,
		["suspensionDamping"] = 0.12,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.4,
		["suspensionLowerLimit"] = -0.25,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x4088,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x8001,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[458] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 150,
		["engineAcceleration"] = 20,
		["engineInertia"] = 100,
		["driveType"] = "awd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 3000,
		["turnMass"] = 5500,
		["dragCoeff"] = 2,
		["centerofmass"] = {0, -0.0, -0.0},
		["percentSubmerged"] = 75,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.24,
		
		--WheelSettings
		["tractionMultiplier"] = 0.75,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.52,
		["brakeDeceleration"] = 8,
        ["brakeBias"] = 0.75,
		["suspensionForceLevel"] = 1.2,
		["suspensionDamping"] = 0.2,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.27,
		["suspensionLowerLimit"] = -0.17,
		["suspensionAntiDiveMultiplier"] = 0.2,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x2020,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x400001,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[461] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 190,
		["engineAcceleration"] = 22,
		["engineInertia"] = 5,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 500,
		["turnMass"] = 161.5,
		["dragCoeff"] = 8,
		["centerofmass"] = {0, 0.05, -0.09},
		["percentSubmerged"] = 103,
		["animGroup"] = 4,
		["seatOffsetDistance"] = 0,
		
		--WheelSettings
		["tractionMultiplier"] = 1.6,
		["tractionLoss"] = 0.9,
		["tractionBias"] = 0.48,
		["brakeDeceleration"] = 15,
        ["brakeBias"] = 0.5,
		["suspensionForceLevel"] = 0.85,
		["suspensionDamping"] = 0.15,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.15,
		["suspensionLowerLimit"] = -0.16,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x1002000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x0,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[463] = {
		--Engine Settings
		["numberOfGears"] = 4,
		["maxVelocity"] = 190,
		["engineAcceleration"] = 16,
		["engineInertia"] = 5,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 800,
		["turnMass"] = 403.3,
		["dragCoeff"] = 5,
		["centerofmass"] = {0, 0.1, 0.0},
		["percentSubmerged"] = 103,
		["animGroup"] = 6,
		["seatOffsetDistance"] = 0,
		
		--WheelSettings
		["tractionMultiplier"] = 1.3,
		["tractionLoss"] = 0.82,
		["tractionBias"] = 0.51,
		["brakeDeceleration"] = 10,
        ["brakeBias"] = 0.55,
		["suspensionForceLevel"] = 0.65,
		["suspensionDamping"] = 0.2,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.09,
		["suspensionLowerLimit"] = -0.11,
		["suspensionAntiDiveMultiplier"] = 0.0,
		["suspensionFrontRearBias"] = 0.55,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x1002000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x0,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[475] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 230,
		["engineAcceleration"] = 10,
		["engineInertia"] = 10,
		["driveType"] = "awd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1700,
		["turnMass"] = 4000,
		["dragCoeff"] = 2,
		["centerofmass"] = {0, 0.1, 0.00},
		["percentSubmerged"] = 70,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.25,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.53,
		["brakeDeceleration"] = 8,
        ["brakeBias"] = 0.52,
		["suspensionForceLevel"] = 1.3,
		["suspensionDamping"] = 0.08,
		["suspensionHighSpeedDamping"] = 5,
		["suspensionUpperLimit"] = 0.3,
		["suspensionLowerLimit"] = -0.2,
		["suspensionAntiDiveMultiplier"] = 0.25,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x2000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x4400006,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	[479] = {
		--Engine Settings
		["numberOfGears"] = 4,
		["maxVelocity"] = 165,
		["engineAcceleration"] = 6.5,
		["engineInertia"] = 25,
		["driveType"] = "fwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1500,
		["turnMass"] = 3800,
		["dragCoeff"] = 2,
		["centerofmass"] = {0, 0.2, 0.00},
		["percentSubmerged"] = 75,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.24,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 0.85,
		["tractionBias"] = 0.52,
		["brakeDeceleration"] = 6,
        ["brakeBias"] = 0.6,
		["suspensionForceLevel"] = 1,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.27,
		["suspensionLowerLimit"] = -0.17,
		["suspensionAntiDiveMultiplier"] = 0.2,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x2020,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x8801,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					--["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					--["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					--["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					--["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					--["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					--["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
					["tractionLoss"] = 0.0025,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
					["tractionLoss"] = 0.0025,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
					["tractionLoss"] = 0.005,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},
	
	[491] = {
		--Engine Settings
		["numberOfGears"] = 4,
		["maxVelocity"] = 176,
		["engineAcceleration"] = 7.2,
		["engineInertia"] = 15,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1700,
		["turnMass"] = 3435.4,
		["dragCoeff"] = 2.2,
		["centerofmass"] = {0, 0.0, -0.1},
		["percentSubmerged"] = 70,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.26,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 1,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 4.5,
        ["brakeBias"] = 0.25,
		["suspensionForceLevel"] = 0.8,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.31,
		["suspensionLowerLimit"] = -0.15,
		["suspensionAntiDiveMultiplier"] = 0.5,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40002000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x0,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[500] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 140,
		["engineAcceleration"] = 8.2,
		["engineInertia"] = 15,
		["driveType"] = "awd",
		["engineType"] = "diesel",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1300,
		["turnMass"] = 1900,
		["dragCoeff"] = 3,
		["centerofmass"] = {0, 0.2, -0.3},
		["percentSubmerged"] = 85,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.18,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 8,
        ["brakeBias"] = 0.5,
		["suspensionForceLevel"] = 1.2,
		["suspensionDamping"] = 0.08,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.32,
		["suspensionLowerLimit"] = -0.15,
		["suspensionAntiDiveMultiplier"] = 0.4,
		["suspensionFrontRearBias"] = 0.35,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x200840,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x440001,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[502] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 220,
		["engineAcceleration"] = 8,
		["engineInertia"] = 5,
		["driveType"] = "rwd",
		["engineType"] = "diesel",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1600,
		["turnMass"] = 4500,
		["dragCoeff"] = 1.45,
		["centerofmass"] = {0, 0.2, -0.4},
		["percentSubmerged"] = 70,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.2,
		
		--WheelSettings
		["tractionMultiplier"] = 0.9,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.48,
		["brakeDeceleration"] = 10,
        ["brakeBias"] = 0.52,
		["suspensionForceLevel"] = 1.5,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 10,
		["suspensionUpperLimit"] = 0.29,
		["suspensionLowerLimit"] = -0.16,
		["suspensionAntiDiveMultiplier"] = 0.4,
		["suspensionFrontRearBias"] = 0.6,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40002004,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0xC00002,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[505] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 170,
		["engineAcceleration"] = 9,
		["engineInertia"] = 5,
		["driveType"] = "awd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 2500,
		["turnMass"] = 4604.2,
		["dragCoeff"] = 2.5,
		["centerofmass"] = {0, 0.0, -0.5},
		["percentSubmerged"] = 80,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.44,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 0.85,
		["tractionBias"] = 0.54,
		["brakeDeceleration"] = 10,
        ["brakeBias"] = 0.5,
		["suspensionForceLevel"] = 1,
		["suspensionDamping"] = 0.9,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.4,
		["suspensionLowerLimit"] = -0.25,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x2020,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x100005,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[506] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 230,
		["engineAcceleration"] = 15,
		["engineInertia"] = 5,
		["driveType"] = "awd",
		["engineType"] = "diesel",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1400,
		["turnMass"] = 2800,
		["dragCoeff"] = 2,
		["centerofmass"] = {0, 0.1, -0.24},
		["percentSubmerged"] = 70,
		["animGroup"] = 1,
		["seatOffsetDistance"] = 0.4,
		
		--WheelSettings
		["tractionMultiplier"] = 0.9,
		["tractionLoss"] = 0.86,
		["tractionBias"] = 0.48,
		["brakeDeceleration"] = 11,
        ["brakeBias"] = 0.52,
		["suspensionForceLevel"] = 1,
		["suspensionDamping"] = 0.2,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.25,
		["suspensionLowerLimit"] = -0.18,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40002004,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x204000,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},
	
	
	[507] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 165,
		["engineAcceleration"] = 8,
		["engineInertia"] = 10,
		["driveType"] = "fwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 2200,
		["turnMass"] = 5000,
		["dragCoeff"] = 1.8,
		["centerofmass"] = {0, 0.1, -0.1},
		["percentSubmerged"] = 75,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.2,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.46,
		["brakeDeceleration"] = 6,
        ["brakeBias"] = 0.8,
		["suspensionForceLevel"] = 1,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.35,
		["suspensionLowerLimit"] = -0.15,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40002000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x400000,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},


	[508] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 140,
		["engineAcceleration"] = 5.6,
		["engineInertia"] = 25,
		["driveType"] = "fwd",
		["engineType"] = "diesel",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 3500,
		["turnMass"] = 13865.8,
		["dragCoeff"] = 3,
		["centerofmass"] = {0, 0.0, -0.0},
		["percentSubmerged"] = 80,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.46,
		
		--WheelSettings
		["tractionMultiplier"] = 0.62,
		["tractionLoss"] = 0.7,
		["tractionBias"] = 0.46,
		["brakeDeceleration"] = 4.5,
        ["brakeBias"] = 0.6,
		["suspensionForceLevel"] = 1.5,
		["suspensionDamping"] = 0.11,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.3,
		["suspensionLowerLimit"] = -0.15,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x88,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x1,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[516] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 165,
		["engineAcceleration"] = 7,
		["engineInertia"] = 20,
		["driveType"] = "fwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1400,
		["turnMass"] = 4000,
		["dragCoeff"] = 2,
		["centerofmass"] = {0, 0.3, -0.1},
		["percentSubmerged"] = 75,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.2,
		
		--WheelSettings
		["tractionMultiplier"] = 0.8,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 8,
        ["brakeBias"] = 0.9,
		["suspensionForceLevel"] = 1.4,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.27,
		["suspensionLowerLimit"] = -0.09,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.59,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x0,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x400000,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[518] = {
		--Engine Settings
		["numberOfGears"] = 4,
		["maxVelocity"] = 160,
		["engineAcceleration"] = 8,
		["engineInertia"] = 15,
		["driveType"] = "rwd",
		["engineType"] = "diesel",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 2200,
		["turnMass"] = 4500,
		["dragCoeff"] = 2.2,
		["centerofmass"] = {0, 0.0, -0.0},
		["percentSubmerged"] = 70,
		["animGroup"] = 1,
		["seatOffsetDistance"] = 0.3,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 0.86,
		["tractionBias"] = 0.45,
		["brakeDeceleration"] = 5,
        ["brakeBias"] = 0.52,
		["suspensionForceLevel"] = 0.8,
		["suspensionDamping"] = 0.3,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.2,
		["suspensionLowerLimit"] = -0.18,
		["suspensionAntiDiveMultiplier"] = 0.4,
		["suspensionFrontRearBias"] = 0.54,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40000004,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x400000,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[529] = {
		--Engine Settings
		["numberOfGears"] = 4,
		["maxVelocity"] = 160,
		["engineAcceleration"] = 7.2,
		["engineInertia"] = 15,
		["driveType"] = "rwd",
		["engineType"] = "diesel",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1800,
		["turnMass"] = 4350,
		["dragCoeff"] = 2,
		["centerofmass"] = {0, 0.0, -0.0},
		["percentSubmerged"] = 70,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.26,
		
		--WheelSettings
		["tractionMultiplier"] = 0.8,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.52,
		["brakeDeceleration"] = 5.4,
        ["brakeBias"] = 0.6,
		["suspensionForceLevel"] = 1.1,
		["suspensionDamping"] = 0.15,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.32,
		["suspensionLowerLimit"] = -0.14,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40000000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x0,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[536] = {
		--Engine Settings
		["numberOfGears"] = 4,
		["maxVelocity"] = 160,
		["engineAcceleration"] = 5.5,
		["engineInertia"] = 5,
		["driveType"] = "rwd",
		["engineType"] = "diesel",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1500,
		["turnMass"] = 2500,
		["dragCoeff"] = 1.5,
		["centerofmass"] = {0, -0.2, 0.1},
		["percentSubmerged"] = 70,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.3,
		
		--WheelSettings
		["tractionMultiplier"] = 0.75,
		["tractionLoss"] = 0.84,
		["tractionBias"] = 0.53,
		["brakeDeceleration"] = 8.17,
        ["brakeBias"] = 0.52,
		["suspensionForceLevel"] = 1,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.3,
		["suspensionLowerLimit"] = -0.15,
		["suspensionAntiDiveMultiplier"] = 0.25,
		["suspensionFrontRearBias"] = 0.44,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40202000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x12010002,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[546] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 160,
		["engineAcceleration"] = 7,
		["engineInertia"] = 25,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1800,
		["turnMass"] = 4350,
		["dragCoeff"] = 1,
		["centerofmass"] = {0, -0.0, 0.0},
		["percentSubmerged"] = 70,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.26,
		
		--WheelSettings
		["tractionMultiplier"] = 0.8,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.49,
		["brakeDeceleration"] = 7,
        ["brakeBias"] = 0.6,
		["suspensionForceLevel"] = 1,
		["suspensionDamping"] = 0.09,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.32,
		["suspensionLowerLimit"] = -0.15,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.54,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x0,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x2,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[547] = {
		--Engine Settings
		["numberOfGears"] = 4,
		["maxVelocity"] = 160,
		["engineAcceleration"] = 7.2,
		["engineInertia"] = 7,
		["driveType"] = "fwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1600,
		["turnMass"] = 3300,
		["dragCoeff"] = 2.2,
		["centerofmass"] = {0, -0.0, 0.0},
		["percentSubmerged"] = 70,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.26,
		
		--WheelSettings
		["tractionMultiplier"] = 0.75,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.54,
		["brakeDeceleration"] = 8,
        ["brakeBias"] = 0.6,
		["suspensionForceLevel"] = 1.1,
		["suspensionDamping"] = 0.14,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.32,
		["suspensionLowerLimit"] = -0.14,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x0,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x0,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[551] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 165,
		["engineAcceleration"] = 8,
		["engineInertia"] = 10,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1800,
		["turnMass"] = 4500,
		["dragCoeff"] = 2.2,
		["centerofmass"] = {0, 0.2, -0.1},
		["percentSubmerged"] = 75,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.2,
		
		--WheelSettings
		["tractionMultiplier"] = 0.8,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.49,
		["brakeDeceleration"] = 10,
        ["brakeBias"] = 0.55,
		["suspensionForceLevel"] = 1.1,
		["suspensionDamping"] = 0.15,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.27,
		["suspensionLowerLimit"] = -0.08,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.54,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40000000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x400001,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},


	[554] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 170,
		["engineAcceleration"] = 10,
		["engineInertia"] = 15,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 32,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 3000,
		["turnMass"] = 6000,
		["dragCoeff"] = 3,
		["centerofmass"] = {0, 0.35, -0.0},
		["percentSubmerged"] = 80,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.44,
		
		--WheelSettings
		["tractionMultiplier"] = 0.6,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.4,
		["brakeDeceleration"] = 8.5,
        ["brakeBias"] = 0.3,
		["suspensionForceLevel"] = 1,
		["suspensionDamping"] = 0.12,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.24,
		["suspensionLowerLimit"] = -0.02,
		["suspensionAntiDiveMultiplier"] = 0.5,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x20200020,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x504400,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	[559] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 260,
		["engineAcceleration"] = 11.2,
		["engineInertia"] = 10,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1500,
		["turnMass"] = 3600,
		["dragCoeff"] = 2.2,
		["centerofmass"] = {0, 0.0, -0.05},
		["percentSubmerged"] = 75,
		["animGroup"] = 1,
		["seatOffsetDistance"] = 0.25,
		
		--WheelSettings
		["tractionMultiplier"] = 0.85,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 10,
        ["brakeBias"] = 0.45,
		["suspensionForceLevel"] = 1.1,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.28,
		["suspensionLowerLimit"] = -0.15,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0xC0002804,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x4000001,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					--["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					--["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					--["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 1,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 4,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 5,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["tractionLoss"] = 0.05,
					--["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 4, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["tractionLoss"] = 0.05,
					--["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 5, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["tractionLoss"] = 0.25,
					--["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,
					["tractionMultiplier"] = 0.025,					
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionMultiplier"] = 0.025,		
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionMultiplier"] = 0.05,		
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},
	
	[579] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 160,
		["engineAcceleration"] = 10,
		["engineInertia"] = 25,
		["driveType"] = "awd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 2500,
		["turnMass"] = 6000,
		["dragCoeff"] = 2.5,
		["centerofmass"] = {0, 0.0, -0.2},
		["percentSubmerged"] = 80,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.44,
		
		--WheelSettings
		["tractionMultiplier"] = 0.62,
		["tractionLoss"] = 0.89,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 7,
        ["brakeBias"] = 0.45,
		["suspensionForceLevel"] = 1,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.45,
		["suspensionLowerLimit"] = -0.21,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.45,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x2000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x2204,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[581] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 290,
		["engineAcceleration"] = 20,
		["engineInertia"] = 5,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 500,
		["turnMass"] = 200,
		["dragCoeff"] = 4.5,
		["centerofmass"] = {0, 0.01, -0.09},
		["percentSubmerged"] = 103,
		["animGroup"] = 4,
		["seatOffsetDistance"] = 0.0,
		
		--WheelSettings
		["tractionMultiplier"] = 1.4,
		["tractionLoss"] = 0.9,
		["tractionBias"] = 0.48,
		["brakeDeceleration"] = 15,
        ["brakeBias"] = 0.5,
		["suspensionForceLevel"] = 0.85,
		["suspensionDamping"] = 0.15,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.15,
		["suspensionLowerLimit"] = -0.2,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x1000000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x1,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[585] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 165,
		["engineAcceleration"] = 9,
		["engineInertia"] = 20,
		["driveType"] = "rwd",
		["engineType"] = "diesel",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1800,
		["turnMass"] = 4000,
		["dragCoeff"] = 2.2,
		["centerofmass"] = {0, 0.2, 0.15},
		["percentSubmerged"] = 75,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.2,
		
		--WheelSettings
		["tractionMultiplier"] = 0.65,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.52,
		["brakeDeceleration"] = 8,
        ["brakeBias"] = 0.45,
		["suspensionForceLevel"] = 0.9,
		["suspensionDamping"] = 0.13,
		["suspensionHighSpeedDamping"] = 3,
		["suspensionUpperLimit"] = 0.3,
		["suspensionLowerLimit"] = -0.1,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40002000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x400000,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[586] = {
		--Engine Settings
		["numberOfGears"] = 4,
		["maxVelocity"] = 190,
		["engineAcceleration"] = 16,
		["engineInertia"] = 5,
		["driveType"] = "rwd",
		["engineType"] = "diesel",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 800,
		["turnMass"] = 600,
		["dragCoeff"] = 4,
		["centerofmass"] = {0, 0.1, 0.0},
		["percentSubmerged"] = 103,
		["animGroup"] = 8,
		["seatOffsetDistance"] = 0,
		
		--WheelSettings
		["tractionMultiplier"] = 1.4,
		["tractionLoss"] = 0.85,
		["tractionBias"] = 0.48,
		["brakeDeceleration"] = 10,
        ["brakeBias"] = 0.55,
		["suspensionForceLevel"] = 0.65,
		["suspensionDamping"] = 0.2,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.09,
		["suspensionLowerLimit"] = -0.11,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.55,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x41002000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x0,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[602] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 200,
		["engineAcceleration"] = 9.2,
		["engineInertia"] = 5,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.5,
		
		--BodySettings
		["mass"] = 1450,
		["turnMass"] = 3400,
		["dragCoeff"] = 2,
		["centerofmass"] = {0, 0.1, -0.2},
		["percentSubmerged"] = 85,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.25,
		
		--WheelSettings
		["tractionMultiplier"] = 0.7,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 7,
        ["brakeBias"] = 0.55,
		["suspensionForceLevel"] = 1.2,
		["suspensionDamping"] = 0.12,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.3,
		["suspensionLowerLimit"] = -0.15,
		["suspensionAntiDiveMultiplier"] = 0.4,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40002800,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x0,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	-- CIVILIAN --
	-- FK vehs
	[416] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 250,
		["engineAcceleration"] = 8,
		["engineInertia"] = 10,
		["driveType"] = "awd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.2,
		
		--BodySettings
		["mass"] = 2600,
		["turnMass"] = 10000,
		["dragCoeff"] = 1.4,
		["centerofmass"] = {0.0, 0.0, 0.0},
		["percentSubmerged"] = 90,
		["animGroup"] = 13,
		["seatOffsetDistance"] = 0.58,
		
		--WheelSettings
		["tractionMultiplier"] = 0.8,
		["tractionLoss"] = 0.9,
		["tractionBias"] = 0.45,
		["brakeDeceleration"] = 10,
        ["brakeBias"] = 0.75,
		["suspensionForceLevel"] = 2,
		["suspensionDamping"] = 0.5,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.4,
		["suspensionLowerLimit"] = -0.2,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x5001,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x4404406,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[490] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 170,
		["engineAcceleration"] = 8.8,
		["engineInertia"] = 5,
		["driveType"] = "awd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.2,
		
		--BodySettings
		["mass"] = 3500,
		["turnMass"] = 11156.2,
		["dragCoeff"] = 1.3,
		["centerofmass"] = {0, 0.0, -0.2},
		["percentSubmerged"] = 80,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.44,
		
		--WheelSettings
		["tractionMultiplier"] = 0.9,
		["tractionLoss"] = 0.8,
		["tractionBias"] = 0.52,
		["brakeDeceleration"] = 9,
        ["brakeBias"] = 0.5,
		["suspensionForceLevel"] = 0.7,
		["suspensionDamping"] = 0.15,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.34,
		["suspensionLowerLimit"] = -0.2,
		["suspensionAntiDiveMultiplier"] = 0.5,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x4020,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x400003,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					--["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					--["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					--["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[528] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 170,
		["engineAcceleration"] = 7,
		["engineInertia"] = 25,
		["driveType"] = "awd",
		["engineType"] = "diesel",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.15,
		
		--BodySettings
		["mass"] = 4000,
		["turnMass"] = 10000,
		["dragCoeff"] = 2,
		["centerofmass"] = {0, 0.0, -0.2},
		["percentSubmerged"] = 85,
		["animGroup"] = 13,
		["seatOffsetDistance"] = 0.32,
		
		--WheelSettings
		["tractionMultiplier"] = 0.65,
		["tractionLoss"] = 0.85,
		["tractionBias"] = 0.54,
		["brakeDeceleration"] = 8,
        ["brakeBias"] = 0.55,
		["suspensionForceLevel"] = 0.8,
		["suspensionDamping"] = 0.1,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.3,
		["suspensionLowerLimit"] = -0.15,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.45,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x1001,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x400003,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},
	
	[596] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 250,
		["engineAcceleration"] = 12,
		["engineInertia"] = 15,
		["driveType"] = "awd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.24,
		
		--BodySettings
		["mass"] = 2000,
		["turnMass"] = 4500,
		["dragCoeff"] = 1.4,
		["centerofmass"] = {0, 0.3, -0.1},
		["percentSubmerged"] = 75,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.2,
		
		--WheelSettings
		["tractionMultiplier"] = 0.8,--0.8
		["tractionLoss"] = 0.9,  --0.8
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 12,
        ["brakeBias"] = 0.75,
		["suspensionForceLevel"] = 1,
		["suspensionDamping"] = 0.12,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.28,
		["suspensionLowerLimit"] = -0.12,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.55,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40002000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x240009,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[597] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 250,
		["engineAcceleration"] = 11,
		["engineInertia"] = 20,
		["driveType"] = "awd",
		["engineType"] = "petrol",
		["steeringLock"] = 35,
		["collisionDamageMultiplier"] = 0.24,
		
		--BodySettings
		["mass"] = 2000,
		["turnMass"] = 4500,
		["dragCoeff"] = 0.5,
		["centerofmass"] = {0, 0.3, -0.15},
		["percentSubmerged"] = 75,
		["animGroup"] = 0,
		["seatOffsetDistance"] = 0.2,
		
		--WheelSettings
		["tractionMultiplier"] = 0.85,
		["tractionLoss"] = 0.9,
		["tractionBias"] = 0.55,
		["brakeDeceleration"] = 12,
        ["brakeBias"] = 0.75,
		["suspensionForceLevel"] = 1.1,
		["suspensionDamping"] = 0.12,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.28,
		["suspensionLowerLimit"] = -0.17,
		["suspensionAntiDiveMultiplier"] = 0,
		["suspensionFrontRearBias"] = 0.55,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x40002000,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x240009,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},

	
	[598] = {
        --Engine Settings
        ["numberOfGears"] = 5,
        ["maxVelocity"] = 200,
        ["engineAcceleration"] = 9.6,
        ["engineInertia"] = 10,
        ["driveType"] = "rwd",
        ["engineType"] = "petrol",
        ["steeringLock"] = 30,
        ["collisionDamageMultiplier"] = 0.24,

        --BodySettings
        ["mass"] = 1400,
        ["turnMass"] = 2998.3,
        ["dragCoeff"] = 2.2,
        ["centerofmass"] = {0, 0.0, -0.1},
        ["percentSubmerged"] = 75,
        ["animGroup"] = 1,
        ["seatOffsetDistance"] = 0.25,

        --WheelSettings
        ["tractionMultiplier"] = 0.75,
        ["tractionLoss"] = 0.9,
        ["tractionBias"] = 0.5,
        ["brakeDeceleration"] = 9,
        ["brakeBias"] = 0.55,
        ["suspensionForceLevel"] = 1.4,
        ["suspensionDamping"] = 0.15,
        ["suspensionHighSpeedDamping"] = 0,
        ["suspensionUpperLimit"] = 0.1,
        ["suspensionLowerLimit"] = -0.05,
        ["suspensionAntiDiveMultiplier"] = 0.0,
        ["suspensionFrontRearBias"] = 0.5,

        --ModelFlags (Vehicle Model Settings)
        ["modelFlags"] = 0x804,

        --HandlingFlags (Special Handling Settings)
        ["handlingFlags"] = 0x4000003,
		
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},
	-- FK vehs --
	
	-- PP Vehs --
	[565] = {
		--Engine Settings
		["numberOfGears"] = 5,
		["maxVelocity"] = 200,
		["engineAcceleration"] = 9.6,
		["engineInertia"] = 10,
		["driveType"] = "rwd",
		["engineType"] = "petrol",
		["steeringLock"] = 30,
		["collisionDamageMultiplier"] = 0.24,
		
		--BodySettings
		["mass"] = 1400,
		["turnMass"] = 2998.3,
		["dragCoeff"] = 0.5,
		["centerofmass"] = {0, 0.0, -0.1},
		["percentSubmerged"] = 75,
		["animGroup"] = 1,
		["seatOffsetDistance"] = 0.25,
		
		--WheelSettings
		["tractionMultiplier"] = 0.75,
		["tractionLoss"] = 0.9,
		["tractionBias"] = 0.5,
		["brakeDeceleration"] = 9,
        ["brakeBias"] = 0.55,
		["suspensionForceLevel"] = 1.4,
		["suspensionDamping"] = 0.15,
		["suspensionHighSpeedDamping"] = 0,
		["suspensionUpperLimit"] = 0.28,
		["suspensionLowerLimit"] = -0.1,
		["suspensionAntiDiveMultiplier"] = 0.3,
		["suspensionFrontRearBias"] = 0.5,
		
		--ModelFlags (Vehicle Model Settings)
		["modelFlags"] = 0x804,
		
		--HandlingFlags (Special Handling Settings)
		["handlingFlags"] = 0x4000003,
	
		--Other Settings
		["tuningFlags"] = {
            ["engine"] = {
                [1] = {
                    ["maxVelocity"] = 5,
					["engineAcceleration"] = 0.5,
					--["dragCoeff"] = 0.1,
                },
				
				[2] = {
                    ["maxVelocity"] = 10,
					["engineAcceleration"] = 1, 
					--["dragCoeff"] = 0.15,
                },

				[3] = {
                    ["maxVelocity"] = 15,
					["engineAcceleration"] = 1.5, 
					--["dragCoeff"] = 0.2,
                },

                ["maxLevel"] = 3,
            },

            ["turbo"] = {
                [1] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 1,
                },
				
				[2] = {
					["engineAcceleration"] = 0.25,
                    ["engineInertia"] = 3,
                },

				[3] = {
					["engineAcceleration"] = 0.5,
                    ["engineInertia"] = 5,
                },

                ["maxLevel"] = 3,
            },

            ["ecu"] = {
                [1] = {
					["maxVelocity"] = 1,
					["dragCoeff"] = -0.1,
                },
				
				[2] = {
					["maxVelocity"] = 2,
					["dragCoeff"] = -0.15,
                },

				[3] = {
					["maxVelocity"] = 3,
					["dragCoeff"] = -0.2,
                },

                ["maxLevel"] = 3,
            },

            ["gearbox"] = {
                [1] = {
                    ["maxVelocity"] = 1, 
                    ["engineAcceleration"] = 0.5,
					["engineInertia"] = 1,
					--["dragCoeff"] = 0.03,
                },
				
				[2] = {
                    ["maxVelocity"] = 2, 
                    ["engineAcceleration"] = 0.8,
					["engineInertia"] = 2,
					--["dragCoeff"] = 0.04,
                },

				[3] = {
                    ["maxVelocity"] = 3, 
                    ["engineAcceleration"] = 1,
					["engineInertia"] = 3,
					--["dragCoeff"] = 0.05,
                },

                ["maxLevel"] = 3,
            },

            ["suspension"] = {
                [1] = {
                    ["suspensionForceLevel"] = 0.05,	
					["tractionBias"] = -0.02,
                },
				
				[2] = {
                    ["suspensionForceLevel"] = 0.1,	
					["tractionBias"] = -0.03,
                },

				[3] = {
                    ["suspensionForceLevel"] = 0.15,	
					["tractionBias"] = -0.05,
                },
				
                ["maxLevel"] = 3,
            },

            ["brakes"] = {
                [1] = {
                    ["brakeDeceleration"] = 1,
                }, 
				
				[2] = {
                    ["brakeDeceleration"] = 2,
                }, 

				[3] = {
                    ["brakeDeceleration"] = 3,
                }, 
				
                ["maxLevel"] = 3,
            },

            ["weight"] = {
                [1] = {
                    ["mass"] = -5,
                },

				[2] = {
                    ["mass"] = -10,
                },

				[3] = {
                    ["mass"] = -15,
                },

                ["maxLevel"] = 3,
            },

            ["steeringLock"] = {
                [1] = {
                    ["steeringLock"] = 10,
                }, 

				[2] = {
                    ["steeringLock"] = 20,
                }, 

				[3] = {
                    ["steeringLock"] = 30,
                }, 

                ["maxLevel"] = 3,
            },

            ["airrideLevel"] = {
                [1] = {
                    ["suspensionLowerLimit"] = 0.1,
                },

				[2] = {
                    ["suspensionLowerLimit"] = 0.05,
                },

                [3] = {
                    ["suspensionLowerLimit"] = 0,
                },

				[4] = {
                    ["suspensionLowerLimit"] = -0.05,
                },

                [5] = {
                    ["suspensionLowerLimit"] = -0.1,
                },

            },
        },
	},
}
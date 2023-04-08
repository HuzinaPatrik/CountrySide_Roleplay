selectedMenu = 1
selectedSubMenu = 1

gray = "#828282"

mdcDutyTypes = {
    [1] = "járőr",
    [2] = "üldözés",
    [3] = "akció",
}

adminDataStats = {
    [1] = "Bejelentkezések száma: @A",
    [2] = "Körözött járművek száma: @B",
    [3] = "Körözött személyek száma: @C",
    [4] = "Büntetések száma: @D",
    [5] = "Összes felhasználó: @E",
    [6] = "Bejelentkezett felhasználók: @F",
}

menus = {
    {
        ["name"] = "Körözött járművek",
        ["icon"] = "wantedcars",
        textBars = {
            ["mdc.wantedCarType"] = {maxLength = 25, inputId = 2},
            ["mdc.wantedCarPlate"] = {maxLength = 10, inputId = 3},
            ["mdc.wantedCarReason"] = {maxLength = 40, inputId = 4}
        }
    },

    {
        ["name"] = "Körözött személyek",
        ["icon"] = "wantedpersons",
        textBars = {
            ["mdc.wantedPersonName"] = {maxLength = 20, inputId = 5},
            ["mdc.wantedPersonNationality"] = {maxLength = 10, inputId = 6},
            ["mdc.wantedPersonDescription"] = {maxLength = 40, inputId = 7},
            ["mdc.wantedPersonReason"] = {maxLength = 40, inputId = 8}
        }
    },

    {
        ["name"] = "Büntetések",
        ["icon"] = "tickets",
        textBars = {
            ["mdc.ticketName"] = {maxLength = 20, inputId = 9},
            ["mdc.penalty"] = {maxLength = 4, onlyNumber = true, inputId = 10},
            ["mdc.jailTime"] = {maxLength = 3, onlyNumber = true, inputId = 11},
            ["mdc.ticketReason"] = {maxLength = 45, inputId = 12}
        }
    },

    {
        ["name"] = "Körözött fegyverek",
        ["icon"] = "weapon",
        textBars = {
            ["mdc.weaponName"] = {maxLength = 30, inputId = 13},
            ["mdc.weaponType"] = {maxLength = 15, inputId = 14},
            ["mdc.weaponSerial"] = {maxLength = 15, inputId = 15},
            ["mdc.weaponReason"] = {maxLength = 45, inputId = 16}
        }
    },

    {
        ["name"] = "Fegyver nyilvántartás",
        ["icon"] = "book",
        textBars = {
            ["mdc.weaponRegistrationOwnerName"] = {maxLength = 30, inputId = 17},
            ["mdc.weaponRegistrationWeaponType"] = {maxLength = 15, inputId = 18},
            ["mdc.weaponRegistrationWeaponSerial"] = {maxLength = 15, inputId = 19}
        }
    },

    {
        ["name"] = "Jármű nyilvántartás",
        ["icon"] = "book",
        textBars = {
            ["mdc.vehicleRegistrationOwnerName"] = {maxLength = 15, inputId = 20},
            ["mdc.vehicleRegistrationVehicleType"] = {maxLength = 15, inputId = 21},
            ["mdc.vehicleRegistrationVehiclePlateText"] = {maxLength = 10, inputId = 22},
            ["mdc.vehicleRegistrationVehicleChassis"] = {maxLength = 20, inputId = 23}
        }
    },

    {
        ["name"] = "Lakcím nyilvántartás",
        ["icon"] = "book",
        textBars = {
            ["mdc.addressRegistrationOwnerName"] = {maxLength = 20, inputId = 24},
            ["mdc.addressRegistrationAddress"] = {maxLength = 20, inputId = 25},
            ["mdc.addressRegistrationRegisterStart"] = {maxLength = 25, inputId = 26},
            ["mdc.addressRegistrationExpirationDate"] = {maxLength = 25, inputId = 27}
        }
    },

    {
        ["name"] = "Forgalmi nyilvántartás",
        ["icon"] = "book",
        textBars = {
            ["mdc.trafficRegistrationOwnerName"] = {maxLength = 20, inputId = 28},
            ["mdc.trafficRegistrationVehiclePlateText"] = {maxLength = 10, inputId = 29},
            ["mdc.trafficRegistrationVehicleChassis"] = {maxLength = 20, inputId = 30},
            ["mdc.trafficRegistrationExpirationDate"] = {maxLength = 25, inputId = 31}
        }
    },
}

punishmentMenus = {
    {
        ["name"] = "Jogsértés",
        ["subMenu"] = {
            {
                ["penaltyName"] = "ez az első büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valamiIde egyéb vagy óvadék vagy valamiIde egyéb vagy óvadék vagy valamiIde egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },
        },
    },

    {
        ["name"] = "Szabálysértés",
        ["subMenu"] = {
            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vdawdawdagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },
        },
    },

    {
        ["name"] = "Vétség",
        ["subMenu"] = {
            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },
        },
    },

    {
        ["name"] = "Bűncselekmény",
        ["subMenu"] = {
            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb",
            },

            {
                ["penaltyName"] = "ez egy teszt büntetés",
                ["penalty"] = 5000,
                ["jailTime"] = 60,
                ["other"] = "Ide egyéb vagy óvadék vagy valami",
            },
        },
    },
}

menusMinLine = 1
menusMaxLine = 8

circlesMinLine = 1
circlesMaxLine = 3

mdcWantedCarsMinLine = 1
_mdcWantedCarsMaxLine = 10
mdcWantedCarsMaxLine = _mdcWantedCarsMaxLine

mdcWantedPersonsMinLine = 1
_mdcWantedPersonsMaxLine = 10
mdcWantedPersonsMaxLine = _mdcWantedPersonsMaxLine

mdcTicketsMinLine = 1
_mdcTicketsMaxLine = 10
mdcTicketsMaxLine = _mdcTicketsMaxLine

mdcWantedWeaponsMinLine = 1
_mdcWantedWeaponsMaxLine = 10
mdcWantedWeaponsMaxLine = _mdcWantedWeaponsMaxLine

mdcWeaponRegistrationMinLine = 1
_mdcWeaponRegistrationMaxLine = 10
mdcWeaponRegistrationMaxLine = _mdcWeaponRegistrationMaxLine

mdcVehicleRegistrationMinLine = 1
_mdcVehicleRegistrationMaxLine = 10
mdcVehicleRegistrationMaxLine = _mdcVehicleRegistrationMaxLine

mdcAddressRegistrationMinLine = 1
_mdcAddressRegistrationMaxLine = 10
mdcAddressRegistrationMaxLine = _mdcAddressRegistrationMaxLine

mdcTrafficRegistrationMinLine = 1
_mdcTrafficRegistrationMaxLine = 10
mdcTrafficRegistrationMaxLine = _mdcTrafficRegistrationMaxLine

mdcAdminPanelMinLine = 1
_mdcAdminPanelMaxLine = 10
mdcAdminPanelMaxLine = _mdcAdminPanelMaxLine

adminStatsMinLine = 1
_adminStatsMaxLine = 6
adminStatsMaxLine = _adminStatsMaxLine

mdcLogsMinLine = 1
_mdcLogsMaxLine = 17
mdcLogsMaxLine = _mdcLogsMaxLine

minPunishmentMenuLine = 1
_maxPunishmentMenuLine = 4
maxPunishmentMenuLine = _maxPunishmentMenuLine

punishmentMinLine = 1
_punishmentMaxLine = 17
punishmentMaxLine = _punishmentMaxLine

allowedVehicles = {
    [470] = true,
    [596] = true,
    [597] = true,
    [598] = true,
    [523] = true,
    [528] = true,
    [490] = true,
}

function getAllowedVehicles()
    return allowedVehicles
end

white = "#ffffff"

function getBlipColorByDutyType(dutyType)
    if dutyType == 1 then 
        return exports["cr_core"]:getServerColor("blue2", false)
    elseif dutyType == 3 then 
        return exports["cr_core"]:getServerColor("red", false)
    end

    return 255, 87, 87
end
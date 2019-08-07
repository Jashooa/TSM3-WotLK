-- ------------------------------------------------------------------------------ --
--                            TradeSkillMaster_Crafting                           --
--            http://www.curse.com/addons/wow/tradeskillmaster_crafting           --
--                                                                                --
--             A TradeSkillMaster Addon (http://tradeskillmaster.com)             --
--    All Rights Reserved* - Detailed license information included with addon.    --
-- ------------------------------------------------------------------------------ --

-- load the parent file (TSM) into a local variable
local TSM = select(2, ...)
local WEAPON, ARMOR = GetAuctionItemClasses()

TSM.enchantingName = GetSpellInfo(7411)

TSM.ARMOR_VELLUM = "i:38682"
TSM.ARMOR_VELLUM_II = "i:37602"
TSM.ARMOR_VELLUM_III = "i:43145"
TSM.WEAPON_VELLUM = "i:39349"
TSM.WEAPON_VELLUM_II = "i:39350"
TSM.WEAPON_VELLUM_III = "i:43146"

-- looks up the itemString of the scroll that the enchant makes
-- index = spellId of the enchant
-- itemString = itemString of scroll
-- itemType = what kind of item the enchantment is for
-- minItemLevel = the minimum item level required
TSM.enchantingItemIDs = {
    [27837] = { itemString = "i:38896", itemType = WEAPON, minItemLevel = 1 }, --  Enchant 2H Weapon - Agility
    [13937] = { itemString = "i:38845", itemType = WEAPON, minItemLevel = 1 }, --  Enchant 2H Weapon - Greater Impact
    [44630] = { itemString = "i:38992", itemType = WEAPON, minItemLevel = 60 }, --  Enchant 2H Weapon - Greater Savagery
    [13695] = { itemString = "i:38822", itemType = WEAPON, minItemLevel = 1 }, --  Enchant 2H Weapon - Impact
    [13529] = { itemString = "i:38796", itemType = WEAPON, minItemLevel = 1 }, --  Enchant 2H Weapon - Lesser Impact
    [7793] = { itemString = "i:38781", itemType = WEAPON, minItemLevel = 1 }, --  Enchant 2H Weapon - Lesser Intellect
    [13380] = { itemString = "i:38788", itemType = WEAPON, minItemLevel = 1 }, --  Enchant 2H Weapon - Lesser Spirit
    [27977] = { itemString = "i:38922", itemType = WEAPON, minItemLevel = 35 }, --  Enchant 2H Weapon - Major Agility
    [20036] = { itemString = "i:38875", itemType = WEAPON, minItemLevel = 1 }, --  Enchant 2H Weapon - Major Intellect
    [20035] = { itemString = "i:38874", itemType = WEAPON, minItemLevel = 1 }, --  Enchant 2H Weapon - Major Spirit
    [60691] = { itemString = "i:44463", itemType = WEAPON, minItemLevel = 60 }, --  Enchant 2H Weapon - Massacre
    [7745] = { itemString = "i:38772", itemType = WEAPON, minItemLevel = 1 }, --  Enchant 2H Weapon - Minor Impact
    [27971] = { itemString = "i:38919", itemType = WEAPON, minItemLevel = 35 }, --  Enchant 2H Weapon - Savagery
    [44595] = { itemString = "i:38981", itemType = WEAPON, minItemLevel = 60 }, --  Enchant 2H Weapon - Scourgebane
    [20030] = { itemString = "i:38869", itemType = WEAPON, minItemLevel = 1 }, --  Enchant 2H Weapon - Superior Impact
    [62948] = { itemString = "i:45056", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Staff - Greater Spellpower
    [62959] = { itemString = "i:45060", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Staff - Spellpower
    [59619] = { itemString = "i:44497", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Accuracy
    [23800] = { itemString = "i:38880", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Agility
    [28004] = { itemString = "i:38927", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Battlemaster
    [59621] = { itemString = "i:44493", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Berserking
    [59625] = { itemString = "i:43987", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Black Magic
    [64441] = { itemString = "i:46026", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Blade Ward
    [64579] = { itemString = "i:46098", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Blood Draining
    [20034] = { itemString = "i:38873", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Crusader
    [46578] = { itemString = "i:38998", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Deathfrost
    [13915] = { itemString = "i:38840", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Demonslaying
    [44633] = { itemString = "i:38995", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Exceptional Agility
    [44629] = { itemString = "i:38991", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Exceptional Spellpower
    [44510] = { itemString = "i:38963", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Exceptional Spirit
    [42974] = { itemString = "i:38948", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Executioner
    [13898] = { itemString = "i:38838", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Fiery Weapon
    [44621] = { itemString = "i:38988", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Giant Slayer
    [42620] = { itemString = "i:38947", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Greater Agility
    [60621] = { itemString = "i:44453", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Greater Potency
    [13943] = { itemString = "i:38848", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Greater Striking
    [22750] = { itemString = "i:38878", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Healing Power
    [44524] = { itemString = "i:38965", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Icebreaker
    [20029] = { itemString = "i:38868", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Icy Chill
    [13653] = { itemString = "i:38813", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Lesser Beastslayer
    [13655] = { itemString = "i:38814", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Lesser Elemental Slayer
    [13503] = { itemString = "i:38794", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Lesser Striking
    [20032] = { itemString = "i:38871", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Lifestealing
    [44576] = { itemString = "i:38972", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Lifeward
    [34010] = { itemString = "i:38946", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Major Healing
    [27968] = { itemString = "i:38918", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Major Intellect
    [27975] = { itemString = "i:38921", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Major Spellpower
    [27967] = { itemString = "i:38917", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Major Striking
    [23804] = { itemString = "i:38884", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Mighty Intellect
    [60714] = { itemString = "i:44467", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Mighty Spellpower
    [23803] = { itemString = "i:38883", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Mighty Spirit
    [7786] = { itemString = "i:38779", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Minor Beastslayer
    [7788] = { itemString = "i:38780", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Minor Striking
    [27984] = { itemString = "i:38925", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Mongoose
    [27972] = { itemString = "i:38920", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Potency
    [27982] = { itemString = "i:38924", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Soulfrost
    [22749] = { itemString = "i:38877", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Spellpower
    [28003] = { itemString = "i:38926", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Spellsurge
    [23799] = { itemString = "i:38879", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Strength
    [13693] = { itemString = "i:38821", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Striking
    [27981] = { itemString = "i:38923", itemType = WEAPON, minItemLevel = 35 }, --  Enchant Weapon - Sunfire
    [60707] = { itemString = "i:44466", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Superior Potency
    [20031] = { itemString = "i:38870", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Superior Striking
    [62257] = { itemString = "i:44946", itemType = WEAPON, minItemLevel = 60 }, --  Enchant Weapon - Titanguard
    [20033] = { itemString = "i:38872", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Unholy Weapon
    [21931] = { itemString = "i:38876", itemType = WEAPON, minItemLevel = 1 }, --  Enchant Weapon - Winter's Might
    [13935] = { itemString = "i:38844", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Agility
    [60606] = { itemString = "i:44449", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Boots - Assault
    [34008] = { itemString = "i:38944", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Boots - Boar's Speed
    [34007] = { itemString = "i:38943", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Boots - Cat's Swiftness
    [27951] = { itemString = "i:37603", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Boots - Dexterity
    [27950] = { itemString = "i:38909", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Boots - Fortitude
    [20023] = { itemString = "i:38863", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Greater Agility
    [60763] = { itemString = "i:44469", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Boots - Greater Assault
    [44528] = { itemString = "i:38966", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Boots - Greater Fortitude
    [44508] = { itemString = "i:38961", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Boots - Greater Spirit
    [20020] = { itemString = "i:38862", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Greater Stamina
    [44584] = { itemString = "i:38974", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Boots - Greater Vitality
    [60623] = { itemString = "i:38986", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Boots - Icewalker
    [63746] = { itemString = "i:45628", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Lesser Accuracy
    [13637] = { itemString = "i:38807", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Lesser Agility
    [13687] = { itemString = "i:38819", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Lesser Spirit
    [13644] = { itemString = "i:38810", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Lesser Stamina
    [7867] = { itemString = "i:38786", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Minor Agility
    [13890] = { itemString = "i:38837", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Minor Speed
    [7863] = { itemString = "i:38785", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Minor Stamina
    [20024] = { itemString = "i:38864", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Spirit
    [13836] = { itemString = "i:38830", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Boots - Stamina
    [44589] = { itemString = "i:38976", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Boots - Superior Agility
    [27954] = { itemString = "i:38910", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Boots - Surefooted
    [47901] = { itemString = "i:39006", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Boots - Tuskarr's Vitality
    [27948] = { itemString = "i:38908", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Boots - Vitality
    [34002] = { itemString = "i:38938", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Bracer - Assault
    [27899] = { itemString = "i:38897", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Bracer - Brawn
    [13931] = { itemString = "i:38842", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Deflection
    [44598] = { itemString = "i:38984", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Bracer - Expertise
    [27914] = { itemString = "i:38902", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Bracer - Fortitude
    [20008] = { itemString = "i:38852", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Greater Intellect
    [13846] = { itemString = "i:38832", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Greater Spirit
    [13945] = { itemString = "i:38849", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Greater Stamina
    [13939] = { itemString = "i:38846", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Greater Strength
    [23802] = { itemString = "i:38882", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Healing Power
    [13822] = { itemString = "i:38829", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Intellect
    [13646] = { itemString = "i:38811", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Lesser Deflection
    [13622] = { itemString = "i:38803", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Lesser Intellect
    [7859] = { itemString = "i:38783", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Lesser Spirit
    [13501] = { itemString = "i:38793", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Lesser Stamina
    [13536] = { itemString = "i:38797", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Lesser Strength
    [27906] = { itemString = "i:38899", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Bracer - Major Defense
    [34001] = { itemString = "i:38937", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Bracer - Major Intellect
    [62256] = { itemString = "i:44947", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Bracer - Major Stamina
    [23801] = { itemString = "i:38881", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Mana Regeneration
    [7779] = { itemString = "i:38777", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Minor Agility
    [7428] = { itemString = "i:38768", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Minor Deflection
    [7418] = { itemString = "i:38679", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Minor Health
    [7766] = { itemString = "i:38774", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Minor Spirit
    [7457] = { itemString = "i:38771", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Minor Stamina
    [7782] = { itemString = "i:38778", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Minor Strength
    [27913] = { itemString = "i:38901", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Bracer - Restore Mana Prime
    [27917] = { itemString = "i:38903", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Bracer - Spellpower
    [13642] = { itemString = "i:38809", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Spirit
    [13648] = { itemString = "i:38812", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Stamina
    [27905] = { itemString = "i:38898", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Bracer - Stats
    [13661] = { itemString = "i:38817", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Strength
    [27911] = { itemString = "i:38900", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Bracer - Superior Healing
    [60767] = { itemString = "i:44470", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Bracer - Superior Spellpower
    [20009] = { itemString = "i:38853", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Superior Spirit
    [20011] = { itemString = "i:38855", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Superior Stamina
    [20010] = { itemString = "i:38854", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Bracer - Superior Strength
    [44555] = { itemString = "i:38968", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Bracers - Exceptional Intellect
    [44575] = { itemString = "i:44815", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Bracers - Greater Assault
    [44635] = { itemString = "i:38997", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Bracers - Greater Spellpower
    [44616] = { itemString = "i:38987", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Bracers - Greater Stats
    [44593] = { itemString = "i:38980", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Bracers - Major Spirit
    [60616] = { itemString = "i:38971", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Bracers - Striking
    [46594] = { itemString = "i:38999", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Chest - Defense
    [27957] = { itemString = "i:38911", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Chest - Exceptional Health
    [27958] = { itemString = "i:38912", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Chest - Exceptional Mana
    [44588] = { itemString = "i:38975", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Chest - Exceptional Resilience
    [27960] = { itemString = "i:38913", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Chest - Exceptional Stats
    [47766] = { itemString = "i:39002", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Chest - Greater Defense
    [13640] = { itemString = "i:38808", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Greater Health
    [13663] = { itemString = "i:38818", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Greater Mana
    [44509] = { itemString = "i:38962", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Chest - Greater Mana Restoration
    [20025] = { itemString = "i:38865", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Greater Stats
    [7857] = { itemString = "i:38782", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Health
    [13538] = { itemString = "i:38798", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Lesser Absorption
    [7748] = { itemString = "i:38773", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Lesser Health
    [7776] = { itemString = "i:38776", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Lesser Mana
    [13700] = { itemString = "i:38824", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Lesser Stats
    [20026] = { itemString = "i:38866", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Major Health
    [20028] = { itemString = "i:38867", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Major Mana
    [33992] = { itemString = "i:38930", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Chest - Major Resilience
    [33990] = { itemString = "i:38928", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Chest - Major Spirit
    [13607] = { itemString = "i:38799", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Mana
    [44492] = { itemString = "i:38955", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Chest - Mighty Health
    [7426] = { itemString = "i:38767", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Minor Absorption
    [7420] = { itemString = "i:38766", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Minor Health
    [7443] = { itemString = "i:38769", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Minor Mana
    [13626] = { itemString = "i:38804", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Minor Stats
    [60692] = { itemString = "i:44465", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Chest - Powerful Stats
    [33991] = { itemString = "i:38929", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Chest - Restore Mana Prime
    [13941] = { itemString = "i:38847", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Stats
    [47900] = { itemString = "i:39005", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Chest - Super Health
    [44623] = { itemString = "i:38989", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Chest - Super Stats
    [13858] = { itemString = "i:38833", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Superior Health
    [13917] = { itemString = "i:38841", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Chest - Superior Mana
    [13635] = { itemString = "i:38806", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Defense
    [25086] = { itemString = "i:38895", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Cloak - Dodge
    [13657] = { itemString = "i:38815", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Fire Resistance
    [34004] = { itemString = "i:38940", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Cloak - Greater Agility
    [34005] = { itemString = "i:38941", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Cloak - Greater Arcane Resistance
    [13746] = { itemString = "i:38825", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Greater Defense
    [25081] = { itemString = "i:38891", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Greater Fire Resistance
    [25082] = { itemString = "i:38892", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Greater Nature Resistance
    [20014] = { itemString = "i:38858", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Greater Resistance
    [34006] = { itemString = "i:38942", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Cloak - Greater Shadow Resistance
    [47898] = { itemString = "i:39003", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Greater Speed
    [13882] = { itemString = "i:38835", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Lesser Agility
    [7861] = { itemString = "i:38784", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Lesser Fire Resistance
    [13421] = { itemString = "i:38790", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Lesser Protection
    [13522] = { itemString = "i:38795", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Lesser Shadow Resistance
    [60663] = { itemString = "i:44457", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Major Agility
    [27961] = { itemString = "i:38914", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Cloak - Major Armor
    [27962] = { itemString = "i:38915", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Cloak - Major Resistance
    [47672] = { itemString = "i:39001", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Mighty Armor
    [13419] = { itemString = "i:38789", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Minor Agility
    [7771] = { itemString = "i:38775", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Minor Protection
    [7454] = { itemString = "i:38770", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Minor Resistance
    [13794] = { itemString = "i:38826", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Resistance
    [44631] = { itemString = "i:38993", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Shadow Armor
    [60609] = { itemString = "i:44456", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Speed
    [34003] = { itemString = "i:38939", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Cloak - Spell Penetration
    [44582] = { itemString = "i:38973", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Spell Piercing
    [25083] = { itemString = "i:38893", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Stealth
    [47051] = { itemString = "i:39000", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Cloak - Steelweave
    [25084] = { itemString = "i:38894", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Subtlety
    [44500] = { itemString = "i:38959", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Superior Agility
    [44596] = { itemString = "i:38982", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Superior Arcane Resistance
    [20015] = { itemString = "i:38859", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Cloak - Superior Defense
    [44556] = { itemString = "i:38969", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Superior Fire Resistance
    [44483] = { itemString = "i:38950", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Superior Frost Resistance
    [44494] = { itemString = "i:38956", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Superior Nature Resistance
    [44590] = { itemString = "i:38977", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Superior Shadow Resistance
    [44591] = { itemString = "i:38978", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Titanweave
    [47899] = { itemString = "i:39004", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Cloak - Wisdom
    [13868] = { itemString = "i:38834", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Advanced Herbalism
    [13841] = { itemString = "i:38831", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Advanced Mining
    [13815] = { itemString = "i:38827", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Agility
    [71692] = { itemString = "i:50816", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Angler
    [44625] = { itemString = "i:38990", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Gloves - Armsman
    [33996] = { itemString = "i:38934", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Gloves - Assault
    [33993] = { itemString = "i:38931", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Gloves - Blasting
    [60668] = { itemString = "i:44458", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Gloves - Crusher
    [44592] = { itemString = "i:38979", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Gloves - Exceptional Spellpower
    [44484] = { itemString = "i:38951", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Gloves - Expertise
    [25078] = { itemString = "i:38888", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Fire Power
    [13620] = { itemString = "i:38802", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Fishing
    [25074] = { itemString = "i:38887", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Frost Power
    [44506] = { itemString = "i:38960", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Gloves - Gatherer
    [20012] = { itemString = "i:38856", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Greater Agility
    [44513] = { itemString = "i:38964", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Gloves - Greater Assault
    [44612] = { itemString = "i:38985", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Gloves - Greater Blasting
    [20013] = { itemString = "i:38857", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Greater Strength
    [25079] = { itemString = "i:38889", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Healing Power
    [13617] = { itemString = "i:38801", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Herbalism
    [44529] = { itemString = "i:38967", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Gloves - Major Agility
    [33999] = { itemString = "i:38936", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Gloves - Major Healing
    [33997] = { itemString = "i:38935", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Gloves - Major Spellpower
    [33995] = { itemString = "i:38933", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Gloves - Major Strength
    [13612] = { itemString = "i:38800", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Mining
    [13948] = { itemString = "i:38851", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Minor Haste
    [33994] = { itemString = "i:38932", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Gloves - Precise Strikes
    [44488] = { itemString = "i:38953", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Gloves - Precision
    [13947] = { itemString = "i:38850", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Riding Skill
    [25073] = { itemString = "i:38886", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Shadow Power
    [13698] = { itemString = "i:38823", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Skinning
    [13887] = { itemString = "i:38836", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Strength
    [25080] = { itemString = "i:38890", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Superior Agility
    [25072] = { itemString = "i:38885", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Gloves - Threat
    [44489] = { itemString = "i:38954", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Shield - Defense
    [13933] = { itemString = "i:38843", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Frost Resistance
    [60653] = { itemString = "i:44455", itemType = ARMOR, minItemLevel = 60 }, --  Enchant Shield - Greater Intellect
    [13905] = { itemString = "i:38839", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Greater Spirit
    [20017] = { itemString = "i:38861", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Greater Stamina
    [27945] = { itemString = "i:38905", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Shield - Intellect
    [13689] = { itemString = "i:38820", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Lesser Block
    [13464] = { itemString = "i:38791", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Lesser Protection
    [13485] = { itemString = "i:38792", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Lesser Spirit
    [13631] = { itemString = "i:38805", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Lesser Stamina
    [34009] = { itemString = "i:38945", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Shield - Major Stamina
    [13378] = { itemString = "i:38787", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Minor Stamina
    [44383] = { itemString = "i:38949", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Shield - Resilience
    [27947] = { itemString = "i:38907", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Shield - Resistance
    [27946] = { itemString = "i:38906", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Shield - Shield Block
    [13659] = { itemString = "i:38816", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Spirit
    [13817] = { itemString = "i:38828", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Stamina
    [27944] = { itemString = "i:38904", itemType = ARMOR, minItemLevel = 35 }, --  Enchant Shield - Tough Shield
    [20016] = { itemString = "i:38860", itemType = ARMOR, minItemLevel = 1 }, --  Enchant Shield - Vitality
}

-------------------------------------------
--Classes and their stats
-------------------------------------------
 
Classes = {}
Classes[1] = {
    NAME = "Human",
    COST = 0,
    WEAPON = "human_gun",
    DESCRIPTION = "This is the default starting class armed with a glock. Play this class if you plan on saving for a more expensive class such as Ninja or Hitman.",
    SPECIALABILITY = "Right click to call hacks!",
    SPECIALABILITY_COST = 0,
    HEALTH = 100,
    SPEED = 250,
    MODEL = "models/player/Kleiner.mdl",
    JUMPOWER = 200
}
 
Classes[2] = {
    NAME = "Gunner",
    COST = 6000,
    WEAPON = "gunner_gun",
    DESCRIPTION = "This class is armed with a desert eagle, dealing significantly more damage per shot than the Human's pistol. This is a great class if you're just starting off and want to have some extra money in the bank.",
    SPECIALABILITY = "Allows you to deflect bullets, consuming \n(amount of damage * 2) energy every time you deflect. \nYour energy does not regenerate, so once depleted, you take bullet damage. \nBullet damage greater than your current energy will deplete it and do full damage. \nSpecial only active while weilding the desert eagle.",
    SPECIALABILITY_COST = 30000,
    HEALTH = 100,
    SPEED = 170,
    MODEL = "models/player/Barney.mdl",
    JUMPOWER = 200
}
 
Classes[3] = {
    NAME = "Ninja",
    COST = 15000,
    WEAPON = "ninja_gun",
    DESCRIPTION = "This class is armed with a USP, able to jump high, run fast and take no fall damage. Ninja is a great budget option for ball control.",
    SPECIALABILITY = "Right click to perform a super jump for 100 energy.",
    SPECIALABILITY_COST = 25000,
    HEALTH = 80,
    SPEED = 300,
    MODEL = "models/player/mossman.mdl",
    JUMPOWER = 500
}
 
Classes[4] = {
    NAME = "Hitman",
    COST = 20000,
    WEAPON = "hitman_gun",
    DESCRIPTION = "This class is armed with a scout sniper rifle. With only one shot per magazine, you must use precision and accuracy to take down enemies from a distance.",
    SPECIALABILITY,
    SPECIALABILITY_COST,
    HEALTH = 100,
    SPEED = 250,
    MODEL = "models/player/breen.mdl",
    JUMPOWER = 200
}
 
Classes[5] = {
    NAME = "Golem",
    COST = 25000,
    WEAPON = "golem_gun",
    DESCRIPTION = "This is a very tanky class armed with an M249 LMG holding 75 rounds.",
    SPECIALABILITY = "Reduce damage you take by 50% for \n4 seconds at the cost of 100 energy.",
    SPECIALABILITY_COST = 45000,
    HEALTH = 150,
    SPEED = 150,
    MODEL = "models/player/monk.mdl",
    JUMPOWER = 200
}
 
Classes[6] = {
    NAME = "Predator",
    COST = 55000,
    WEAPON = "pred_gun",
    DESCRIPTION = "This class weilds a knife, able to kill any enemy with a backstab, and is able to cloak with right click. This class is best used in bases, whether it be defending your own base, or sneaking into an enemy base.",
    SPECIALABILITY,
    SPECIALABILITY_COST,
    HEALTH = 120,
    SPEED = 250,
    MODEL = "models/player/gman_high.mdl",
    JUMPOWER = 200
}
 
Classes[7] = {
    NAME = "Juggernaught",
    COST = 60000,
    WEAPON = "jugg_gun",
    DESCRIPTION = "This class is the tankiest of them all, weilding an M3 pump shotgun. This defensive class is best used in close quarters, and is great for guarding a base.",
    SPECIALABILITY,
    SPECIALABILITY_COST,
    HEALTH = 200,
    SPEED = 150,
    MODEL = "models/player/odessa.mdl",
    JUMPOWER = 200
}
 
Classes[8] = {
    NAME = "Bomber",
    COST = 70000,
    WEAPON = "bomber_gun",
    DESCRIPTION = "This class uses C4 to blow himself and surrounding enemies up. He is best in close quarters, and also deals significant damage to bases.",
	SPECIALABILITY = "Place a destroyable bomb on the ground that \ndetonates after 8 seconds. These small bombs deal heavy damage \nto props. Consumes 100 energy.",
	SPECIALABILITY_COST = 40000, 
    HEALTH = 180,
    SPEED = 230,
    MODEL = "models/player/Eli.mdl",
    JUMPOWER = 200
}
 
Classes[9] = {
    NAME = "Swat",
    COST = 50000,
    WEAPON = "swat_gun",
    DESCRIPTION = "This class is armed with an M4A1, able to deal significant damage at medium distances. This class will generally do well on any map, and is best played offensively.",
    SPECIALABILITY = "Your M4A1 can now launch grenades at the cost of 100 energy.",
    SPECIALABILITY_COST = 45000,
    HEALTH = 100,
    SPEED = 230,
    MODEL = "models/player/Combine_Super_Soldier.mdl",
    JUMPOWER = 200
}
 
Classes[10] = {
    NAME = "Terrorist",
    COST = 55000,
    WEAPON = "terrorist_gun",
    DESCRIPTION = "This class carries an AK47, comparable to Swat's M4A1. In comparison to Swat, this class has slightly more damage, but less accuracy. Terrorist also has slightly more health.",
    SPECIALABILITY = "Continue firing after your magazine \nhas emptied at the cost of 20 energy per bullet.",
    SPECIALABILITY_COST = 35000,
    HEALTH = 120,
    SPEED = 220,
    MODEL = "models/player/Combine_Soldier_PrisonGuard.mdl",
    JUMPOWER = 200
}
 
Classes[11] = {
    NAME = "Sorcerer",
    COST = 50000,
    WEAPON = "sorcerer_gun",
    DESCRIPTION = "This mage type class uses energy to shoot bolts of lightning accurately at long distances. With good aim, this class can be deadly.",
	SPECIALABILITY = "Toggles seeking for a target that is 500 units \nor closer, then casting chain lightning dealing 70 damage to \nthe first target hit, and 50% damage to a second target.\nConsumes 100 energy.",
	SPECIALABILITY_COST = 50000, 
    HEALTH = 80,
    SPEED = 230,
    MODEL = "models/player/soldier_stripped.mdl",
    JUMPOWER = 200
}
 
Classes[12] = {
    NAME = "Neo",
    COST = 70000,
    WEAPON = "neo_gun",
    DESCRIPTION = "This class is armed with rapid firing dual elites and the ability to use energy to jump far distances. Gravity is not Neo's friend, so be careful of high falls. This class is best used for ball control.",
    SPECIALABILITY,
    SPECIALABILITY_COST,
    HEALTH = 90,
    SPEED = 230,
    MODEL = "models/player/charple.mdl",
    JUMPOWER = 200
}
 
Classes[13] = {
    NAME = "Assassin",
    COST = 60000,
    WEAPON = "assassin_gun",
    DESCRIPTION = "This class is similar to hitman, but has 3 bullets in his sniper's magazine, and is able to fire rapidly. Assassin is most effective in a high spot, or sniping from a distance.",
    SPECIALABILITY = "Enables a second level of zoom on your \nsniper, also allows you to reload twice as fast for 100 energy.",
    SPECIALABILITY_COST = 35000, 
    HEALTH = 100,
    SPEED = 170,
    MODEL = "models/player/gman_high.mdl",
    JUMPOWER = 200
}
 
Classes[14] = {
    NAME = "Advancer",
    COST = 45000,
    WEAPON = "advancer_gun",
    DESCRIPTION = "This class is armed with a slow firing P90 and moves very slowly. Advancer's special ability is a must have, allowing this class to be one of the most agile, and is great for ball control.",
    SPECIALABILITY = "While crouched, double tap A or D to launch \nyou in that direction at the cost of 50 energy.",
    SPECIALABILITY_COST = 30000,
    HEALTH = 120,
    SPEED = 120,
    MODEL = "models/player/charple.mdl",
    JUMPOWER = 200
}
 
Classes[15] = {
    NAME = "RocketMan",
    COST = 60000,
    WEAPON = "arena_rocket",
    DESCRIPTION = "This class uses a rocket launcher, able to deal huge damage with a direct hit. Due to his rockets swaying in the wind, it isn't easy hitting players from a long distance. Bases are bigger though, so Rocketman is great at taking down bases with a barrage of rockets from a distance.",
	SPECIALABILITY = "Attach a laser pointer to your rocket launcher \nallowing your next rocket to be laser-guided. Consumes 100 energy.",
	SPECIALABILITY_COST = 30000, 
    HEALTH = 160,
    SPEED = 120,
    MODEL = "models/player/odessa.mdl",
    JUMPOWER = 200
}
Classes[16] = {
    NAME = "Grenadier",
    COST = 60000,
    WEAPON = "grenade_gun",
    DESCRIPTION = "This class tosses grenades, able to deal lethal explosive damage in a small area around the grenade. This class is best used in close quarters with multiple targets to toss grenades at.",
	SPECIALABILITY = "Throw a grenade with extra velocity \nthat will explode on contact. Consumes 100 energy.",
	SPECIALABILITY_COST = 40000, 
    HEALTH = 80,
    SPEED = 120,
    MODEL = "models/player/odessa.mdl",
    JUMPOWER = 200
}
 
Classes[17] = {
    NAME = "Raider",
    COST = 10000,
    WEAPON = "raider_gun",
    DESCRIPTION = "This class is agile and weilds a MAC-10. Raider is a good budget offensive class.",
    SPECIALABILITY = "Increase running speed by 200% \nfor the cost of 25 energy per second.",
    SPECIALABILITY_COST = 40000,
    HEALTH = 80,
    SPEED = 250,
    MODEL = "models/player/Group03/male_03.mdl",
    JUMPOWER = 200
}
 
Classes[18] = {
    NAME = "Guardian",
    COST = 12000,
    WEAPON = "guardian_gun",
    DESCRIPTION = "This class has a double barrel shotgun and is able to deal devistating damage in close range, but has a slow reload time. This class is a good budget defensive class, and is great for guarding a base.",
    SPECIALABILITY,
    SPECIALABILITY_COST,
    HEALTH = 130,
    SPEED = 150,
    MODEL = "models/player/police.mdl",
    JUMPOWER = 200
}

Classes[19] = {
    NAME = "PumpkinMan",
    COST = 75000,
    WEAPON = "pumpkinman_gun",
    DESCRIPTION = "Throw pumpkins that seek for enemys ! If it hits an enemy,  you will throw an additional pumpkin for 50 energy.",
    SPECIALABILITY = "You laugh out loud at your enemys... \n \n how humiliating ! MUAHAHAHA !",
    SPECIALABILITY_COST = 25000,
    HEALTH = 60,
    SPEED = 200,
    MODEL = "models/player/monk.mdl",
    JUMPOWER = 200
}
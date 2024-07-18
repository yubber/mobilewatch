settings {
    "lobby": {
        "allowPlayersInQueue": true,
        "enableMatchVoiceChat": true,
        "spectatorSlots": 12,
        "team1Slots": 1,
        "team2Slots": 0
    },
    "gamemodes": {
        "skirmish": {
            "enabledMaps": [
                {
                    "havana": [
                        "morning"
                    ]
                }
            ]
        },
        "general": {
            "healthPackRespawnTime%": 10,
            "heroLimit": "off",
            "spawnHealthPacks": "enabled",
			"enableKillCam": false,
            "tankPassiveHealthBonus": "alwaysEnabled"
        }
    },
    "heroes": {
        "allTeams": {
            "mercy": {
                "weaponsEnabled": "staff"
            },
            "widowmaker": {
                "projectileGravity%": 500,
                "projectileSpeed%": 10
            },
            "hammond": {
                "enableRollOnly": true
            },
            "enabledHeroes": [
                "orisa"
            ]
        }
    }
}

#!include "vars.opy"

/*todo
- ass vibrate when walk
- */

#!define RoadStart vect(-84.9, 3.86, -173.56)
#!define RoadDir vect(-0.71, 0, 0.71)
#!define RoadUnit vect(2.12, 0, 2.12)
# road width is 3*4
# ok so basically the periodt is based on the movespeed of the player... i think at base it's *360???
#!define SwayOffset sinDeg(eventPlayer.walkDuration * 250) * Vector.LEFT * 0.15 - sinDeg(eventPlayer.walkDuration * 500) * Vector.UP * 0.02
# LCheek vect(0.2, 0.5, -0.5) RCheek vect(-0.22, 0.5, -0.5)
#!define RCheek vect(-0.12, 1.3, -0.5) + SwayOffset + vect(-0.17, -0.66, 0) * eventPlayer.asssize
#!define LCheek vect(0.1, 1.3, -0.5) + SwayOffset + vect(0.17, -0.66, 0) * eventPlayer.asssize
#!define BaseSize 0.5

#!define ScreenPos(x, y, CamPos, LookPos, dist) __script__("../screenPos.js")
#!define iknowwhatyouare rgb(128 + 127 * cosDeg(getTotalTimeElapsed() * 100),128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 120),128 + 127 * cosDeg((getTotalTimeElapsed() * 100) + 240))

#!extension spawnMoreDummyBots
#!extension buffStatusEffects

def makeRoadBotPair():
	eventPlayer.temp = random.choice([-1,1])
	createDummy(random.choice(bblTakers), Team.2, -1, eventPlayer.next + eventPlayer.temp * -RoadUnit, -RoadDir)
	eventPlayer.bots.append(getLastCreatedEntity())
	createDummy(random.choice(bblGivers), Team.1, -1, eventPlayer.next + eventPlayer.temp * RoadUnit, -RoadDir)
	eventPlayer.bots.append(getLastCreatedEntity())
	getAllPlayers().startForcingOutlineFor(getAllPlayers(), false, Color.WHITE, OutlineVisibility.DEFAULT)
	getAllPlayers().disableNameplatesFor(getAllPlayers())
	eventPlayer.bots.opp = eventPlayer
	getPlayersOnHero(Hero.MERCY, Team.1).setWeapon(1)
rule "player init":
	@Event eachPlayer
	@Condition eventPlayer.hasSpawned()
	@Condition not eventPlayer.isDummy()
	print(hostPlayer.walkDuration)
	# eventPlayer.startForcingHero(Hero.ORISA)
	eventPlayer.state = STATE.MENU
	eventPlayer.menuState = MENU.MAIN
	chase(eventPlayer.visopt, eventPlayer.option, rate=15, ChaseReeval.DESTINATION_AND_RATE)

	eventPlayer.disableRespawn()
	eventPlayer.rcheek.setMaxHealth(10000)
	eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)
	eventPlayer.disableGamemodeHud()
	eventPlayer.disableHeroHud()
	eventPlayer.disablePlayerCollision()
	eventPlayer.credits = 0
	eventPlayer.owcoins = 0
	eventPlayer.option = 0

	eventPlayer.disallowButton(Button.ABILITY_1)
	eventPlayer.disallowButton(Button.ABILITY_2)
	eventPlayer.disallowButton(Button.ULTIMATE)
	eventPlayer.disallowButton(Button.JUMP)
	eventPlayer.disallowButton(Button.MELEE)
	eventPlayer.disallowButton(Button.PRIMARY_FIRE)
	eventPlayer.disallowButton(Button.SECONDARY_FIRE)
	eventPlayer.disallowButton(Button.ULTIMATE)
	eventPlayer.disallowButton(Button.CROUCH)
rule "global init":
	setMatchTime(4*60+20)
	pauseMatchTime()
	for i in range(1,12,1): # exceeds bot limit to do all at once
		createBeam(getAllPlayers(), Beam.BAD, RoadStart + 10 * i * RoadDir, RoadStart + 10 * i * RoadDir + 4 * Vector.UP, rgb(random.randint(0,255),random.randint(0,255),random.randint(0,255)), EffectReeval.VISIBILITY)
		wait()

	# munny
	hudText(getAllPlayers(), " € ", "overcoins", localPlayer.owcoins, HudPosition.RIGHT, null, Color.YELLOW, Color.YELLOW, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
	hudText(getAllPlayers(), abilityIconString(Hero.ORISA, Button.ABILITY_1), "kotickets", localPlayer.kotix, HudPosition.RIGHT, null, Color.TURQUOISE, Color.TURQUOISE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
	hudText(getAllPlayers(), iconString(Icon.TRASHCAN), "credits", localPlayer.credits, HudPosition.RIGHT, null, Color.WHITE, Color.WHITE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)
	hudText(getAllPlayers(), " B ", "blorbux", localPlayer.blorbux, HudPosition.RIGHT, null, Color.SKY_BLUE, Color.SKY_BLUE, Color.WHITE, HudReeval.VISIBILITY_AND_STRING)

	# andoid button prompts
	createBeam(localPlayer if localPlayer.menuState != MENU.OFF else [], Beam.BAD, ScreenPos(-4, -1.3, "menuCam", "menuLook", 1), ScreenPos(4, -1.3, "menuCam", "menuLook", 1), Color.BLACK, EffectReeval.VISIBILITY)
	createInWorldText(localPlayer if localPlayer.menuState != MENU.OFF else [], "\&left_black_triangle;", ScreenPos(0.4, -1.3, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState != MENU.OFF else [], "[{}]".format(buttonString(Button.INTERACT)), ScreenPos(0.4, -1.43, "menuCam", "menuLook", 100), 2.5, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState != MENU.OFF else [], "\&black_square;", ScreenPos(-0.4, -1.3, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState != MENU.OFF else [], "\&black_circle;", ScreenPos(0, -1.3, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)

	### main menu
	createInWorldText(localPlayer if localPlayer.menuState == MENU.MAIN else [], "mobilewatch 2", menuCam + 100 * (
		0 * crossProduct(directionTowards(menuCam, menuLook), angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90)) +
		(0.3 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90) +
		3 * directionTowards(menuCam, menuLook)), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.ORANGE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.MAIN else [], "{}shop".format("\&right_black_triangle; " if localPlayer.option == 0 else ""), menuCam + 100 * (
		0 * crossProduct(directionTowards(menuCam, menuLook), angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90)) +
		(-0.3 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90) +
		3 * directionTowards(menuCam, menuLook)), 4, Clip.NONE, WorldTextReeval.VISIBILITY_STRING_AND_COLOR, iknowwhatyouare, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.MAIN else [], "{}play".format("\&right_black_triangle; " if localPlayer.option == 1 else ""), menuCam + 100 * (
		0 * crossProduct(directionTowards(menuCam, menuLook), angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90)) +
		(-0.65 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90) +
		3 * directionTowards(menuCam, menuLook)), 3, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

	### shop
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "shop", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, iknowwhatyouare, SpecVisibility.DEFAULT)

	for i in range(menuMaxes[MENU.SHOP]):
		# box
		createBeam(localPlayer if localPlayer.menuState == MENU.SHOP else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * i)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * i)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)
		wait()
	createBeam(localPlayer if localPlayer.menuState == MENU.SHOP else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)

	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "buy overcoins", ScreenPos(-1.7, -0.2, "menuCam", "menuLook", 100), 2.3, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "€", ScreenPos(-1.7, 0, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.ORANGE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "buy kotickets", ScreenPos("(-1.7 + 5/menuMaxes[MENU.SHOP])", -0.2, "menuCam", "menuLook", 100), 2.3, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], abilityIconString(Hero.ORISA, Button.ABILITY_1), ScreenPos("(-1.7 + 5/menuMaxes[MENU.SHOP])", 0, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "buy blorbux", ScreenPos("(-1.7 + 5/menuMaxes[MENU.SHOP] * 2)", -0.2, "menuCam", "menuLook", 100), 2.3, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "B", ScreenPos("(-1.7 + 5/menuMaxes[MENU.SHOP] * 2)", 0, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.SKY_BLUE, SpecVisibility.DEFAULT)

	# buycoin
	createInWorldText(localPlayer if localPlayer.menuState == MENU.BUYCOIN else [], "buy overcoins", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, Color.ORANGE, SpecVisibility.DEFAULT)

	for i in range(len(coinValues)):
		# box
		createBeam(localPlayer if localPlayer.menuState == MENU.BUYCOIN else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5/len(coinValues) * i)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5/len(coinValues) * i)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)
		# txt
		createInWorldText(localPlayer if localPlayer.menuState == MENU.BUYCOIN else [], "€{}".format(coinValues[i]), menuCam + 100 * (
			(-2 + 5/len(coinValues) * i) * crossProduct(directionTowards(menuCam, menuLook), angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90)) +
			(0.5 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90) +
			3 * directionTowards(menuCam, menuLook)), 6, Clip.NONE, WorldTextReeval.VISIBILITY, Color.ORANGE, SpecVisibility.DEFAULT)
		createInWorldText(localPlayer if localPlayer.menuState == MENU.BUYCOIN else [], "${}".format(coinPrices[i]), menuCam + 100 * (
			(-2 + 5/len(coinValues) * i) * crossProduct(directionTowards(menuCam, menuLook), angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90)) +
			(-0.5 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90) +
			3 * directionTowards(menuCam, menuLook)), 2, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
		wait()
	# 1 more
	createBeam(localPlayer if localPlayer.menuState == MENU.BUYCOIN else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)

	# blorbo
	createInWorldText(localPlayer if localPlayer.menuState == MENU.BUYBLORBO else [], "buy blorbux", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, Color.SKY_BLUE, SpecVisibility.DEFAULT)

	for i in range(len(blorboValues)):
		# box
		createBeam(localPlayer if localPlayer.menuState == MENU.BUYBLORBO else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5/len(blorboValues) * i)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5/len(blorboValues) * i)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)
		# txt
		createInWorldText(localPlayer if localPlayer.menuState == MENU.BUYBLORBO else [], "B{}".format(blorboValues[i]), menuCam + 100 * (
			(-2 + 5/len(blorboValues) * i) * crossProduct(directionTowards(menuCam, menuLook), angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90)) +
			(0.5 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90) +
			3 * directionTowards(menuCam, menuLook)), 6, Clip.NONE, WorldTextReeval.VISIBILITY, Color.SKY_BLUE, SpecVisibility.DEFAULT)
		createInWorldText(localPlayer if localPlayer.menuState == MENU.BUYBLORBO else [], "${}".format(blorboPrices[i]), menuCam + 100 * (
			(-2 + 5/len(blorboValues) * i) * crossProduct(directionTowards(menuCam, menuLook), angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90)) +
			(-0.5 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90) +
			3 * directionTowards(menuCam, menuLook)), 2, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
		wait()
	# 1 more
	createBeam(localPlayer if localPlayer.menuState == MENU.BUYBLORBO else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)

	# kotick
	createInWorldText(localPlayer if localPlayer.menuState == MENU.BUYKOTICK else [], "buy kotickets", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, Color.TURQUOISE, SpecVisibility.DEFAULT)

	for i in range(len(kotickValues)):
		# box
		createBeam(localPlayer if localPlayer.menuState == MENU.BUYKOTICK else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5/len(blorboValues) * i)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5/len(blorboValues) * i)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)
		# txt
		createInWorldText(localPlayer if localPlayer.menuState == MENU.BUYKOTICK else [], "{}{}".format(abilityIconString(Hero.ORISA, Button.ABILITY_1), kotickValues[i]), menuCam + 100 * (
			(-2 + 5/len(kotickValues) * i) * crossProduct(directionTowards(menuCam, menuLook), angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90)) +
			(0.5 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90) +
			3 * directionTowards(menuCam, menuLook)), 6, Clip.NONE, WorldTextReeval.VISIBILITY, Color.SKY_BLUE, SpecVisibility.DEFAULT)
		createInWorldText(localPlayer if localPlayer.menuState == MENU.BUYKOTICK else [], "${}".format(kotickPrices[i]), menuCam + 100 * (
			(-2 + 5/len(kotickValues) * i) * crossProduct(directionTowards(menuCam, menuLook), angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90)) +
			(-0.5 - 0.200) * angleToDirection(horizontalAngleOfDirection(directionTowards(menuCam, menuLook)), verticalAngleOfDirection(directionTowards(menuCam, menuLook)) - 90) +
			3 * directionTowards(menuCam, menuLook)), 2, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
		wait()
	# 1 more
	createBeam(localPlayer if localPlayer.menuState == MENU.BUYKOTICK else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)

	# top beams
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.GRAPPLE, ScreenPos(-2.5, 0.6, "menuCam", "menuLook", 2), ScreenPos(2.5, 0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)

	### selector
	# L
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.GOOD, ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * localPlayer.visopt)", 0.6, "menuCam", "menuLook", 1), ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * localPlayer.visopt)", -0.6, "menuCam", "menuLook", 1), Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	# R
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.GOOD, ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt + 1))", 0.6, "menuCam", "menuLook", 1), ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt + 1))", -0.6, "menuCam", "menuLook", 1), Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	# T
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.GOOD, ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt))", 0.6, "menuCam", "menuLook", 1), ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt + 1))", 0.6, "menuCam", "menuLook", 1), Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	# B
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.GOOD, ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt))", -0.6, "menuCam", "menuLook", 1), ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt + 1))", -0.6, "menuCam", "menuLook", 1), Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

rule "bbl+":
	@Event eachPlayer
	@Disabled
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.isHoldingButton(Button.PRIMARY_FIRE)
	eventPlayer.asssize += 0.05

rule "bbl-":
	@Event eachPlayer
	@Disabled
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.isHoldingButton(Button.SECONDARY_FIRE)
	eventPlayer.asssize -= 0.05
### game behavior
rule "level init":
	@Event eachPlayer
	@Condition eventPlayer.hasSpawned()
	@Condition eventPlayer.state == STATE.GAME
	@Condition not eventPlayer.isDummy()
	eventPlayer.menuState = MENU.OFF
	eventPlayer.teleport(RoadStart)
	# eventPlayer.startFacing(RoadDir, 9999, Relativity.TO_WORLD, FacingReeval.NONE)
	eventPlayer.asssize = 1
	eventPlayer.next = RoadStart + 30 * RoadDir
	eventPlayer.stopForcingThrottle()
	eventPlayer.stopThrottleInDirection()

	wait()
	createDummy(Hero.ORISA, Team.2, -1, RoadStart + 122*RoadDir, -RoadDir)
	eventPlayer.opp = getLastCreatedEntity()
	eventPlayer.opp.opp = eventPlayer
	eventPlayer.opp.asssize = 1.5
	wait()

	for eventPlayer.i in range(len(eventPlayer.bots)):
		destroyDummy(eventPlayer.bots[eventPlayer.i].getTeam(), eventPlayer.bots[eventPlayer.i].getSlot())
		wait()
	eventPlayer.bots = []

	eventPlayer.next = RoadStart + 10 * RoadDir

	for eventPlayer.i in range(0,3,1): # exceeds bot limit to do all at once
		# createBeam(getAllPlayers(), Beam.BAD, RoadStart + 10 * eventPlayer.i * RoadDir, RoadStart + 10 * eventPlayer.i * RoadDir + 2 * Vector.UP, rgb(random.randint(0,255),random.randint(0,255),random.randint(0,255)), EffectReeval.VISIBILITY)
		makeRoadBotPair()
		eventPlayer.next += 10 * RoadDir
		wait(0.048)

	eventPlayer.next -= 10 * RoadDir
	wait(0.24)
	getAllPlayers().startForcingOutlineFor(getAllPlayers(), false, Color.WHITE, OutlineVisibility.DEFAULT)
	getAllPlayers().disableNameplatesFor(getAllPlayers())

rule "level cleanup":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.hasSpawned()
	@Condition eventPlayer.state != STATE.GAME
	wait(0.08, Wait.ABORT_WHEN_FALSE)
	for eventPlayer.i in range(len(eventPlayer.bots)):
		destroyDummy(eventPlayer.bots[eventPlayer.i].getTeam(), eventPlayer.bots[eventPlayer.i].getSlot())
		wait()
	eventPlayer.bots = []
	eventPlayer.asssize = 1
	eventPlayer.stopForcingThrottle()
	eventPlayer.stopThrottleInDirection()
	destroyDummy(eventPlayer.opp.getTeam(), eventPlayer.opp.getSlot())
	eventPlayer.setStatusEffect(null, Status.PHASED_OUT, 9999)

rule "spawn next bots":
	@Event eachPlayer
	@Condition eventPlayer.state == STATE.GAME
	@Condition distance(eventPlayer, eventPlayer.next) < 6
	@Condition distance(eventPlayer.next, eventPlayer.opp.getPosition()) > 19
	wait(0.16, Wait.ABORT_WHEN_FALSE)
	eventPlayer.next += 10 * RoadDir

	destroyDummy(eventPlayer.bots[0].getTeam(), eventPlayer.bots[0].getSlot())
	destroyDummy(eventPlayer.bots[1].getTeam(), eventPlayer.bots[1].getSlot())
	eventPlayer.bots = eventPlayer.bots.slice(2,len(eventPlayer.bots)) # having excess in 2nd param is ok

	makeRoadBotPair()

	wait(0.24)
	getAllPlayers().startForcingOutlineFor(getAllPlayers(), false, Color.WHITE, OutlineVisibility.DEFAULT)
	getAllPlayers().disableNameplatesFor(getAllPlayers())

rule "bot act":
	@Event eachPlayer
	@Condition eventPlayer.isDummy()
	@Condition eventPlayer.getCurrentHero() != Hero.ORISA
	@Condition distance(eventPlayer, eventPlayer.opp) < 3
	wait(0.096, Wait.ABORT_WHEN_FALSE)
	eventPlayer.startFacing(directionTowards(eventPlayer,eventPlayer.opp), 999, Relativity.TO_WORLD, FacingReeval.DIRECTION_AND_TURN_RATE)
	switch eventPlayer.getCurrentHero():
		case Hero.MOIRA:
			eventPlayer.forceButtonPress(Button.ABILITY_2)
			wait(0.12)
			eventPlayer.forceButtonPress(Button.SECONDARY_FIRE)
			chase(eventPlayer.opp.asssize, eventPlayer.opp.asssize - 0.1, duration=1.5, ChaseReeval.NONE)
			break
		case Hero.JUNKER_QUEEN:
			eventPlayer.forceButtonPress(Button.ABILITY_2)
			wait(1)
			eventPlayer.opp.asssize -= 0.05
			chase(eventPlayer.opp.asssize, eventPlayer.opp.asssize - 0.05, duration=1, ChaseReeval.NONE)
			break
		case Hero.SIGMA:
			eventPlayer.forceButtonPress(Button.ABILITY_1)
			chase(eventPlayer.opp.asssize, eventPlayer.opp.asssize - 0.1, duration=1.5, ChaseReeval.NONE)
			break
		case Hero.WIDOWMAKER:
			eventPlayer.setProjectileGravity(9999)
			wait()
			eventPlayer.forceButtonPress(Button.ABILITY_2)
			wait(1)
			chase(eventPlayer.opp.asssize, eventPlayer.opp.asssize - 0.1, duration=1.5, ChaseReeval.NONE)
			break
		# bbl
		case Hero.MERCY:
			getPlayersOnHero(Hero.MERCY, Team.1).setWeapon(1)
			eventPlayer.setUltCharge(100)
			wait(0.12)
			eventPlayer.forceButtonPress(Button.ULTIMATE)
			eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
			chase(eventPlayer.opp.asssize, eventPlayer.opp.asssize + 0.2, duration=1.5, ChaseReeval.NONE)
			wait(1.5)
			eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
			break
		case Hero.BAPTISTE:
			eventPlayer.forceButtonPress(Button.ABILITY_1)
			wait(0.12)
			eventPlayer.opp.asssize += 0.2
			break
		case Hero.SOLDIER:
			eventPlayer.forceButtonPress(Button.ABILITY_2)
			chase(eventPlayer.opp.asssize, eventPlayer.opp.asssize + 0.2, duration=1.5, ChaseReeval.NONE)
			break
		case Hero.ANA:
			eventPlayer.setUltCharge(100)
			wait()
			eventPlayer.forceButtonPress(Button.ULTIMATE)
			eventPlayer.opp.asssize += 0.2
			break
		case Hero.LIFEWEAVER:
			eventPlayer.startForcingButton(Button.PRIMARY_FIRE)
			wait(0.4)
			eventPlayer.stopForcingButton(Button.PRIMARY_FIRE)
			wait(0.16)
			eventPlayer.opp.asssize += 0.2
			break
	wait(1.5)
	stopChasingVariable(eventPlayer.opp.asssize)
rule "assnimal kaiser":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition distance(eventPlayer, eventPlayer.opp) < 12
	wait(1, Wait.ABORT_WHEN_FALSE)
	eventPlayer.startThrottleInDirection(directionTowards(eventPlayer, eventPlayer.opp), 1, Relativity.TO_WORLD, Throttle.REPLACE_EXISTING, ThrottleReeval.DIRECTION_AND_MAGNITUDE)

	waitUntil(distance(eventPlayer, eventPlayer.opp) < 1.8, 7)
	eventPlayer.stopThrottleInDirection()
	eventPlayer.startForcingThrottle(0,0,0,0,0,0)
	eventPlayer.stopFacing()
	eventPlayer.startCamera(worldVector(vect(5,0.7,0.8), eventPlayer,Transform.ROTATION_AND_TRANSLATION),eventPlayer.lcheek, 50)
	wait()
	eventPlayer.setFacing(-eventPlayer.getFacingDirection(), Relativity.TO_WORLD)
	eventPlayer.opp.setFacing(-eventPlayer.opp.getFacingDirection(), Relativity.TO_WORLD)
	eventPlayer.setUltCharge(100)
	eventPlayer.opp.setUltCharge(100)
	eventPlayer.clearStatusEffect(Status.PHASED_OUT)
	eventPlayer.opp.clearStatusEffect(Status.PHASED_OUT)
	wait(0.8)
	eventPlayer.allowButton(Button.ULTIMATE)
	eventPlayer.forceButtonPress(Button.ULTIMATE)
	eventPlayer.opp.forceButtonPress(Button.ULTIMATE)
	wait()
	chase(eventPlayer.walkDuration, 9999, rate=9, ChaseReeval.NONE)
	chase(eventPlayer.opp.walkDuration, 9999, rate=9, ChaseReeval.NONE)

	waitUntil(not eventPlayer.isUsingUltimate(), 5)
	stopChasingVariable(eventPlayer.opp.walkDuration)
	stopChasingVariable(eventPlayer.walkDuration)
	if eventPlayer.asssize > eventPlayer.opp.asssize:
		damage(eventPlayer.opp, eventPlayer, 999999)
		eventPlayer.menuState = MENU.WIN
	else:
		damage(eventPlayer, eventPlayer.opp, 999999)
		eventPlayer.menuState = MENU.LOSE

	eventPlayer.stopCamera()
	eventPlayer.is3p = false

rule "i shake it i shake it i shake it ooh":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.menuState == MENU.OFF
	# @Condition eventPlayer.state == STATE.GAME
	@Condition eventPlayer.getThrottle().z != 0
	chase(eventPlayer.walkDuration, 9999, rate=1, ChaseReeval.NONE)
	waitUntil(eventPlayer.getThrottle().z == 0, 9999)
	stopChasingVariable(eventPlayer.walkDuration)
	eventPlayer.walkDuration = 0

### menu
rule "back to back to back to back to you":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.isHoldingButton(Button.INTERACT)
	# @Condition eventPlayer.menuState != MENU.OFF
	eventPlayer.option = 0
	switch eventPlayer.menuState:
		case MENU.SHOP:
			eventPlayer.menuState = MENU.MAIN
			break
		case MENU.BUYBLORBO:
		case MENU.BUYKOTICK:
		case MENU.BUYCOIN:
			eventPlayer.menuState = MENU.SHOP
			break
rule "select":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.isHoldingButton(Button.JUMP)
	@Condition eventPlayer.menuState != MENU.OFF
	switch eventPlayer.menuState:
		case MENU.MAIN:
			if eventPlayer.option == 0:
				eventPlayer.menuState = MENU.SHOP
			elif eventPlayer.option == 1:
				eventPlayer.menuState = MENU.OFF
				eventPlayer.state = STATE.GAME
			break
		case MENU.SHOP:
			eventPlayer.menuState += 1 + eventPlayer.option
			break

rule "menu scroll up":
	@Event eachPlayer
	@Condition eventPlayer.menuState != MENU.OFF
	@Condition eventPlayer.getThrottle().z > 0 or eventPlayer.getThrottle().x > 0
	@Condition not eventPlayer.isDummy()
	playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 30)
	if eventPlayer.option == 0:
		eventPlayer.option = menuMaxes[eventPlayer.menuState] - 1
		# eventPlayer.visopt = menuMaxes[eventPlayer.menuState] - 2
	else:
		eventPlayer.option--
	wait(0.24, Wait.ABORT_WHEN_FALSE)
	if RULE_CONDITION:
		goto RULE_START

rule "menu scroll down":
	@Event eachPlayer
	@Condition eventPlayer.menuState != MENU.OFF
	@Condition eventPlayer.getThrottle().z < 0 or eventPlayer.getThrottle().x < 0
	@Condition not eventPlayer.isDummy()
	playEffect(eventPlayer, DynamicEffect.RING_EXPLOSION_SOUND, Color.WHITE, eventPlayer, 30)
	eventPlayer.option = (eventPlayer.option + 1) % menuMaxes[eventPlayer.menuState]
	wait(0.24, Wait.ABORT_WHEN_FALSE)
	if RULE_CONDITION:
		goto RULE_START

rule "menu hath been opened":
	@Event eachPlayer
	@Condition eventPlayer.hasSpawned()
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.menuState != MENU.OFF
	eventPlayer.startCamera(menuCam, menuLook, 50)
	eventPlayer.setMoveSpeed(1)
	eventPlayer.option = 0
	eventPlayer.stopForcingThrottle()
	eventPlayer.stopThrottleInDirection()

rule "menu closed":
	@Event eachPlayer
	@Condition eventPlayer.menuState == MENU.OFF
	eventPlayer.setMoveSpeed(50)
	eventPlayer.startCamera(
			raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(0, 0.5, -4), eventPlayer, Transform.ROTATION), null, eventPlayer, false).getHitPosition(),
			eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 50, 35)

### bot mgmt
rule "cheek init & cheek loop":
	@Event eachPlayer
	@Hero orisa

	createDummy(Hero.HAMMOND, eventPlayer.getTeam(), -1, Vector.UP * 999, Vector.UP)
	eventPlayer.lcheek = getLastCreatedEntity()
	wait(0.96)
	# eventPlayer.lcheek.attachTo(eventPlayer, LCheek)
	eventPlayer.lcheek.disablePlayerCollision()
	eventPlayer.lcheek.disableEnvironmentCollision(true)
	eventPlayer.lcheek.startForcingPosition(worldVector(LCheek, eventPlayer, Transform.ROTATION_AND_TRANSLATION), true)
	eventPlayer.lcheek.startScalingSize(BaseSize * eventPlayer.asssize, true)
	eventPlayer.lcheek.opp = eventPlayer
	eventPlayer.lcheek.setMaxHealth(10000)
	eventPlayer.lcheek.forceButtonPress(Button.SECONDARY_FIRE)
	eventPlayer.lcheek.setStatusEffect(null, Status.UNKILLABLE, 9999)
	eventPlayer.lcheek.startForcingName("{}'s left cheek".format(eventPlayer))
	createEffect(getAllPlayers(), Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED, Color.TEAM_1 if eventPlayer.getTeam() == Team.1 else Color.TEAM_2, eventPlayer.lcheek, true, EffectReeval.VISIBILITY)

	wait()
	createDummy(Hero.HAMMOND, Team.1, -1, Vector.UP * 999, Vector.UP)
	eventPlayer.rcheek = getLastCreatedEntity()
	wait(0.96)
	# eventPlayer.rcheek.attachTo(eventPlayer, RCheek)
	eventPlayer.rcheek.disablePlayerCollision()
	eventPlayer.rcheek.disableEnvironmentCollision(true)
	eventPlayer.rcheek.startForcingPosition(worldVector(RCheek, eventPlayer, Transform.ROTATION_AND_TRANSLATION), true)
	eventPlayer.rcheek.startScalingSize(BaseSize * eventPlayer.asssize, true)
	eventPlayer.rcheek.opp = eventPlayer
	eventPlayer.rcheek.setMaxHealth(10000)
	eventPlayer.rcheek.forceButtonPress(Button.SECONDARY_FIRE)
	eventPlayer.rcheek.setStatusEffect(null, Status.UNKILLABLE, 9999)
	eventPlayer.rcheek.startForcingName("{}'s right cheek".format(eventPlayer))
	createEffect(getAllPlayers(), Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED, Color.TEAM_1, eventPlayer.rcheek, true, EffectReeval.VISIBILITY)

	wait(1.6)
	getAllPlayers().startForcingOutlineFor(getAllPlayers(), false, Color.WHITE, OutlineVisibility.DEFAULT)
	getAllPlayers().disableNameplatesFor(getAllPlayers())

	wait()
	eventPlayer.rcheek.forceButtonPress(Button.SECONDARY_FIRE)
	wait()
	eventPlayer.lcheek.forceButtonPress(Button.SECONDARY_FIRE)
	getAllPlayers().startForcingOutlineFor(getAllPlayers(), false, Color.WHITE, OutlineVisibility.DEFAULT)

	while entityExists(eventPlayer):
		if not (entityExists(eventPlayer.lcheek) and entityExists(eventPlayer.rcheek)):
			destroyDummy(eventPlayer.lcheek.getTeam(), eventPlayer.lcheek.getSlot())
			destroyDummy(eventPlayer.rcheek.getTeam(), eventPlayer.rcheek.getSlot())
			goto RULE_START
		eventPlayer.rcheek.setHealth(30000)
		eventPlayer.setHealth(70000)
		eventPlayer.lcheek.setHealth(30000)
		damage(getPlayersOnHero(Hero.HAMMOND, Team.ALL), null, 2)
		# damage(eventPlayer.rcheek, null, 2)
		wait(0.8)

rule "delete orphaned bots & asscheeks":
	@Event eachPlayer
	@Condition eventPlayer.isDummy()
	@Condition not entityExists(eventPlayer.opp)
	wait(3, Wait.ABORT_WHEN_FALSE)
	destroyDummy(eventPlayer.getTeam(), eventPlayer.getSlot())

rule "3rd person":
	@Event eachPlayer
	@Disabled
	@Condition eventPlayer.isHoldingButton(Button.INTERACT)
	wait()
	eventPlayer.rcheek.forceButtonPress(Button.SECONDARY_FIRE)
	wait()
	eventPlayer.lcheek.forceButtonPress(Button.SECONDARY_FIRE)
	eventPlayer.is3p = not eventPlayer.is3p
	if eventPlayer.is3p:
		eventPlayer.state = STATE.GAME
		eventPlayer.startCamera(
			raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(0, 0.5, -4), eventPlayer, Transform.ROTATION), null, eventPlayer, false).getHitPosition(),
			eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 50, 35)
		# eventPlayer.startCamera(worldVector(vect(0,1.2,-2), eventPlayer,Transform.ROTATION_AND_TRANSLATION), eventPlayer.getEyePosition() + eventPlayer.getFacingDirection(), 0)
	else:
		eventPlayer.stopCamera()
		for eventPlayer.i in range(len(eventPlayer.bots)):
			destroyDummy(eventPlayer.bots[eventPlayer.i].getTeam(), eventPlayer.bots[eventPlayer.i].getSlot())
			wait()
		eventPlayer.bots = []
		eventPlayer.state = STATE.MENU
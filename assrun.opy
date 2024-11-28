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

# #!extension spawnMoreDummyBots
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
	# @Condition eventPlayer.hasSpawned()
	@Condition not eventPlayer.isDummy()
	@Condition menuCam != null
	# print(hostPlayer.walkDuration)
	wait(0.8)
	eventPlayer.startForcingHero(Hero.ORISA)
	wait(0.64)
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
	wait(2)
	eventPlayer.state = STATE.MENU
	eventPlayer.menuState = MENU.MAIN
	wait(0.064)
	eventPlayer.startCamera(menuCam, menuLook, 50)
rule "global init":
	@Condition menuCam != null
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
	wait()
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


	# top beams
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.GRAPPLE, ScreenPos(-2.5, 0.6, "menuCam", "menuLook", 2), ScreenPos(2.5, 0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.GRAPPLE, ScreenPos(-2.5, -0.6, "menuCam", "menuLook", 2), ScreenPos(2.5, -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)

	### cosmetic menu headers
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SKINS else [], "buy skins", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, Color.ROSE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.PANTS else [], "buy pants", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, Color.ROSE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.HEROES else [], "buy blorbos", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, Color.ROSE, SpecVisibility.DEFAULT)

	for i in range(len(skinNames)):
		wait()
		createInWorldText(localPlayer if localPlayer.menuState == MENU.SKINS else [], skinNames[i], ScreenPos("(-2 + 5/menuMaxes[MENU.SKINS] * i)", 0.5, "menuCam", "menuLook", 100), 2.5, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
		createInWorldText(localPlayer if localPlayer.menuState == MENU.SKINS else [], "selected" if evalOnce(i) == localPlayer.skin else "owned" if evalOnce(i) in localPlayer.skinsOwned else evalOnce("€{}".format(skinPrices[i])), ScreenPos("(-2 + 5/menuMaxes[MENU.SKINS] * i)", -0.5, "menuCam", "menuLook", 100), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
	for i in range(len(pantNames)):
		wait()
		createInWorldText(localPlayer if localPlayer.menuState == MENU.PANTS else [], pantNames[i], ScreenPos("(-2 + 5/menuMaxes[MENU.PANTS] * i)", 0.5, "menuCam", "menuLook", 100), 2.5, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
		createInWorldText(localPlayer if localPlayer.menuState == MENU.PANTS else [], "selected" if evalOnce(i) == localPlayer.pants else "owned" if evalOnce(i) in localPlayer.pantsOwned else evalOnce("{}{}".format(abilityIconString(Hero.ORISA, Button.ABILITY_1), pantPrices[i])), ScreenPos("(-2 + 5/menuMaxes[MENU.PANTS] * i)", -0.5, "menuCam", "menuLook", 100), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)
	for i in range(len(heroNames)):
		wait()
		createInWorldText(localPlayer if localPlayer.menuState == MENU.HEROES else [], heroIcon(heroNames[i]), ScreenPos("(-2 + 5/menuMaxes[MENU.HEROES] * i)", 0.5, "menuCam", "menuLook", 100), 2.5, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
		createInWorldText(localPlayer if localPlayer.menuState == MENU.HEROES else [], "selected" if evalOnce(i) == localPlayer.hero else "owned" if evalOnce(i) in localPlayer.heroesOwned else evalOnce("B{}".format(pantPrices[i])), ScreenPos("(-2 + 5/menuMaxes[MENU.HEROES] * i)", -0.5, "menuCam", "menuLook", 100), 2, Clip.NONE, WorldTextReeval.VISIBILITY_AND_STRING, Color.WHITE, SpecVisibility.DEFAULT)

	### selector
	# L, dir reverse
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.BAD, ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * localPlayer.visopt)", -0.6, "menuCam", "menuLook", 1), ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * localPlayer.visopt)", 0.6, "menuCam", "menuLook", 1.9), Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	# R
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.BAD, ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt + 1))", 0.6, "menuCam", "menuLook", 1.9), ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt + 1))", -0.6, "menuCam", "menuLook", 1), Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	# T
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.BAD, ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt))", 0.6, "menuCam", "menuLook", 1.9), ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt + 1))", 0.6, "menuCam", "menuLook", 1), Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	# B, dir reverse
	createBeam(localPlayer if localPlayer.menuState >= MENU.SHOP else [], Beam.BAD, ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt + 1))", -0.6, "menuCam", "menuLook", 1), ScreenPos("(-2.5 + 5/menuMaxes[localPlayer.menuState] * (localPlayer.visopt))", -0.6, "menuCam", "menuLook", 1.9), Color.TEAM_1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

	# YOU LOSE!
	createInWorldText(localPlayer if localPlayer.menuState == MENU.LOSE else [], "watch ad to\nretry with bbl", ScreenPos(-2, 0, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, iknowwhatyouare, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.LOSE else [], "you lose...", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, Color.GRAY, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.LOSE else [], "return to menu", ScreenPos(-2+5, 0, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)

	createInWorldText(localPlayer if localPlayer.menuState == MENU.WIN else [], "level complete!", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, Color.GRAY, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.WIN else [], "reward: 100 credits {}".format(iconString(Icon.TRASHCAN)), ScreenPos(0, 0, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, iknowwhatyouare, SpecVisibility.DEFAULT)

	hudHeader(localPlayer if localPlayer.state == STATE.AD else [], "{} skip ad".format(localPlayer.adTimer), ScreenPos(0, -1.2, "menuCam", "menuLook", 100), 0, Color.GRAY, HudReeval.VISIBILITY_AND_STRING)
	# createInWorldText(localPlayer if localPlayer.state == STATE.AD else [], "{} skip ad".format(localPlayer.adTimer), ScreenPos(0, -1.2, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.GRAY, SpecVisibility.DEFAULT)
rule "global init - skin effects":
	wait(1.8)
	### skins
	createEffect(localPlayer if ((localPlayer.skin == 1 and localPlayer.menuState != MENU.SKINS) or (localPlayer.menuState == MENU.SKINS and localPlayer.option == 1)) else [], Effect.ANA_NANO_BOOSTED, Color.TEAM_1, localPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.skin == 2 and localPlayer.menuState != MENU.SKINS) or (localPlayer.menuState == MENU.SKINS and localPlayer.option == 2)) else [], Effect.REAPER_WRAITH_FORM, Color.TEAM_1, localPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.skin == 3 and localPlayer.menuState != MENU.SKINS) or (localPlayer.menuState == MENU.SKINS and localPlayer.option == 3)) else [], Effect.WRECKING_BALL_ADAPTIVE_SHIELD_TARGET, Color.TEAM_1, localPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.skin == 4 and localPlayer.menuState != MENU.SKINS) or (localPlayer.menuState == MENU.SKINS and localPlayer.option == 4)) else [], Effect.ECHO_CLONING, Color.TEAM_1, localPlayer, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

	# pants
	createEffect(localPlayer if ((localPlayer.pants == 0 and localPlayer.menuState != MENU.PANTS) or (localPlayer.menuState == MENU.PANTS and localPlayer.option == 0)) else [], Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED, Color.TEAM_1, localPlayer.lcheek, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.pants == 0 and localPlayer.menuState != MENU.PANTS) or (localPlayer.menuState == MENU.PANTS and localPlayer.option == 0)) else [], Effect.BAPTISTE_IMMORTALITY_FIELD_PROTECTED, Color.TEAM_1, localPlayer.rcheek, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.pants == 1 and localPlayer.menuState != MENU.PANTS) or (localPlayer.menuState == MENU.PANTS and localPlayer.option == 1)) else [], Effect.ANA_NANO_BOOSTED, Color.TEAM_1, localPlayer.lcheek, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.pants == 1 and localPlayer.menuState != MENU.PANTS) or (localPlayer.menuState == MENU.PANTS and localPlayer.option == 1)) else [], Effect.ANA_NANO_BOOSTED, Color.TEAM_1, localPlayer.rcheek, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.pants == 2 and localPlayer.menuState != MENU.PANTS) or (localPlayer.menuState == MENU.PANTS and localPlayer.option == 2)) else [], Effect.REAPER_WRAITH_FORM, Color.TEAM_1, localPlayer.lcheek, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.pants == 2 and localPlayer.menuState != MENU.PANTS) or (localPlayer.menuState == MENU.PANTS and localPlayer.option == 2)) else [], Effect.REAPER_WRAITH_FORM, Color.TEAM_1, localPlayer.rcheek, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.pants == 3 and localPlayer.menuState != MENU.PANTS) or (localPlayer.menuState == MENU.PANTS and localPlayer.option == 4)) else [], Effect.ECHO_CLONING, Color.TEAM_1, localPlayer.lcheek, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.pants == 3 and localPlayer.menuState != MENU.PANTS) or (localPlayer.menuState == MENU.PANTS and localPlayer.option == 4)) else [], Effect.ECHO_CLONING, Color.TEAM_1, localPlayer.rcheek, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.pants == 4 and localPlayer.menuState != MENU.PANTS) or (localPlayer.menuState == MENU.PANTS and localPlayer.option == 3)) else [], Effect.WRECKING_BALL_PILEDRIVER_FIRE, Color.TEAM_1, localPlayer.lcheek, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)
	createEffect(localPlayer if ((localPlayer.pants == 4 and localPlayer.menuState != MENU.PANTS) or (localPlayer.menuState == MENU.PANTS and localPlayer.option == 3)) else [], Effect.WRECKING_BALL_PILEDRIVER_FIRE, Color.TEAM_1, localPlayer.rcheek, 1, EffectReeval.VISIBILITY_POSITION_AND_RADIUS)

rule "global init - currency, main PRODUCT menu":
	wait(0.96)
	### shop
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "shop", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, iknowwhatyouare, SpecVisibility.DEFAULT)

	for i in range(menuMaxes[MENU.SHOP]):
		# box
		createBeam(localPlayer if localPlayer.menuState == MENU.SHOP else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * i)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * i)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)
		wait()
	createBeam(localPlayer if localPlayer.menuState == MENU.SHOP else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)

	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "buy skins", ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * 0.5)", 0.2, "menuCam", "menuLook", 100), 2.3, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], iconString(Icon.DIZZY), ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * 0.5)", -0.1, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.SKY_BLUE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "buy pants", ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * 1.5)", 0.2, "menuCam", "menuLook", 100), 2.3, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], abilityIconString(Hero.HAMMOND, Button.ABILITY_1), ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * 1.5)", -0.1, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.SKY_BLUE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "buy blorbos", ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * 2.5)", 0.2, "menuCam", "menuLook", 100), 2.3, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], heroIcon(Hero.ORISA), ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * 2.5)", -0.1, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.SKY_BLUE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "buy currency", ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * 3.5)", 0.2, "menuCam", "menuLook", 100), 2.3, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.SHOP else [], "€{}B".format(abilityIconString(Hero.ORISA, Button.ABILITY_1)), ScreenPos("(-2.5 + 5/menuMaxes[MENU.SHOP] * 3.5)", -0.1, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)

	# currency
	createInWorldText(localPlayer if localPlayer.menuState == MENU.CURRENCY else [], "buy currency", ScreenPos(0, 1.1, "menuCam", "menuLook", 100), 6, Clip.NONE, WorldTextReeval.VISIBILITY_AND_COLOR, iknowwhatyouare, SpecVisibility.DEFAULT)

	for i in range(menuMaxes[MENU.CURRENCY]):
		# box
		createBeam(localPlayer if localPlayer.menuState == MENU.CURRENCY else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5/menuMaxes[MENU.CURRENCY] * i)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5/menuMaxes[MENU.CURRENCY] * i)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)
		wait()
	createBeam(localPlayer if localPlayer.menuState == MENU.CURRENCY else [], Beam.GRAPPLE, ScreenPos("(-2.5 + 5)", 0.6, "menuCam", "menuLook", 2), ScreenPos("(-2.5 + 5)", -0.6, "menuCam", "menuLook", 2), Color.WHITE, EffectReeval.VISIBILITY)

	createInWorldText(localPlayer if localPlayer.menuState == MENU.CURRENCY else [], "overcoins", ScreenPos(-1.7, -0.2, "menuCam", "menuLook", 100), 2.3, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.CURRENCY else [], "€", ScreenPos(-1.7, 0, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.ORANGE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.CURRENCY else [], "kotickets", ScreenPos("(-1.7 + 5/menuMaxes[MENU.CURRENCY])", -0.2, "menuCam", "menuLook", 100), 2.3, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.CURRENCY else [], abilityIconString(Hero.ORISA, Button.ABILITY_1), ScreenPos("(-1.7 + 5/menuMaxes[MENU.CURRENCY])", 0, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.CURRENCY else [], "blorbux", ScreenPos("(-1.7 + 5/menuMaxes[MENU.CURRENCY] * 2)", -0.2, "menuCam", "menuLook", 100), 2.3, Clip.NONE, WorldTextReeval.VISIBILITY, Color.WHITE, SpecVisibility.DEFAULT)
	createInWorldText(localPlayer if localPlayer.menuState == MENU.CURRENCY else [], "B", ScreenPos("(-1.7 + 5/menuMaxes[MENU.CURRENCY] * 2)", 0, "menuCam", "menuLook", 100), 4, Clip.NONE, WorldTextReeval.VISIBILITY, Color.SKY_BLUE, SpecVisibility.DEFAULT)

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
	eventPlayer.startFacing(RoadDir, 9999, Relativity.TO_WORLD, FacingReeval.NONE)
	eventPlayer.asssize = 1
	eventPlayer.next = RoadStart + 30 * RoadDir
	eventPlayer.stopForcingThrottle()
	eventPlayer.stopThrottleInDirection()
	eventPlayer.startCamera(
			raycast(eventPlayer.getEyePosition(), eventPlayer.getEyePosition() + worldVector(vect(0, 0.5, -4), eventPlayer, Transform.ROTATION), null, eventPlayer, false).getHitPosition(),
			eventPlayer.getEyePosition() + eventPlayer.getFacingDirection() * 50, 35)
	eventPlayer.setMoveSpeed(50)

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

	eventPlayer.next -= 20 * RoadDir
	wait(0.24)
	getAllPlayers().startForcingOutlineFor(getAllPlayers(), false, Color.WHITE, OutlineVisibility.DEFAULT)
	getAllPlayers().disableNameplatesFor(getAllPlayers())
	eventPlayer.startForcingThrottle(1,0,0,0,0,1)

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
	@Condition eventPlayer.state == STATE.GAME
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
		wait(2)
		eventPlayer.resurrect()
		eventPlayer.menuState = MENU.LOSE
	# eventPlayer.stopCamera()
	# eventPlayer.is3p = false

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
		case MENU.SKINS:
			# eventPlayer.skin = eventPlayer.temp
		case MENU.PANTS:
			# eventPlayer.pants = eventPlayer.temp
		case MENU.HEROES:
			# eventPlayer.hero = eventPlayer.temp
			eventPlayer.startForcingHero(heroNames[eventPlayer.hero])
		case MENU.CURRENCY:
			eventPlayer.menuState = MENU.SHOP
			eventPlayer.stopForcingPosition()
			wait()
			eventPlayer.teleport(getSpawnPoints(Team.1)[0])
			break
		case MENU.BUYBLORBO:
		case MENU.BUYKOTICK:
		case MENU.BUYCOIN:
			eventPlayer.menuState = MENU.CURRENCY
			break
rule "select":
	@Event eachPlayer
	@Condition not eventPlayer.isDummy()
	@Condition eventPlayer.isHoldingButton(Button.JUMP)
	@Condition eventPlayer.menuState != MENU.OFF
	playEffect(eventPlayer, DynamicEffect.BUFF_IMPACT_SOUND, Color.WHITE, eventPlayer, 50)
	# playEffect(eventPlayer, DynamicEffect.GOOD_PICKUP_EFFECT, Color.ROSE, menuCam, 1)
	switch eventPlayer.menuState:
		case MENU.MAIN:
			if eventPlayer.option == 0:
				eventPlayer.menuState = MENU.SHOP
			elif eventPlayer.option == 1:
				eventPlayer.menuState = MENU.OFF
				eventPlayer.state = STATE.GAME
			eventPlayer.option = 0
			break
		case MENU.SHOP:
			if eventPlayer.option == 0:
				eventPlayer.menuState = MENU.SKINS
				# eventPlayer.temp = eventPlayer.skin
			elif eventPlayer.option == 1:
				eventPlayer.menuState = MENU.PANTS
				# eventPlayer.temp = eventPlayer.pants
			elif eventPlayer.option == 2:
				eventPlayer.menuState = MENU.HEROES
				# eventPlayer.temp = eventPlayer.hero
			elif eventPlayer.option == 3:
				eventPlayer.menuState = MENU.CURRENCY
				goto lbl_0
			eventPlayer.option = 0
			eventPlayer.startForcingPosition(ScreenPos("(-2 + 5/menuMaxes[eventPlayer.menuState] * (eventPlayer.visopt))", -0.3, "menuCam", "menuLook", 3), true)
			lbl_0:
			break
		case MENU.CURRENCY:
			eventPlayer.menuState += 1 + eventPlayer.option
			eventPlayer.option = 0
			break
		case MENU.BUYCOIN:
			eventPlayer.owcoins += coinValues[eventPlayer.option]
			smallMessage(eventPlayer, "thank you for your purchase!")
			break
		case MENU.BUYKOTICK:
			eventPlayer.kotix += kotickValues[eventPlayer.option]
			smallMessage(eventPlayer, "thank you for your purchase!")
			break
		case MENU.BUYBLORBO:
			eventPlayer.blorbux += blorboValues[eventPlayer.option]
			smallMessage(eventPlayer, "thank you for your purchase!")
			break
		case MENU.SKINS:
			if eventPlayer.option in eventPlayer.skinsOwned:
				eventPlayer.skin = eventPlayer.option
			else:
				if eventPlayer.owcoins >= skinPrices[eventPlayer.option]:
					eventPlayer.owcoins -= skinPrices[eventPlayer.option]
					eventPlayer.skinsOwned.append(eventPlayer.option)
					smallMessage(eventPlayer, "purchase successful.")
				else:
					smallMessage(eventPlayer, "insufficient funds.")
					eventPlayer.menuState = MENU.BUYCOIN
			break
		case MENU.PANTS:
			if eventPlayer.option in eventPlayer.pantsOwned:
				eventPlayer.pants = eventPlayer.option
			else:
				if eventPlayer.kotix >= pantPrices[eventPlayer.option]:
					eventPlayer.kotix -= pantPrices[eventPlayer.option]
					eventPlayer.pantsOwned.append(eventPlayer.option)
					smallMessage(eventPlayer, "purchase successful.")
				else:
					smallMessage(eventPlayer, "insufficient funds.")
					eventPlayer.menuState = MENU.BUYKOTICK
			break
		case MENU.HEROES:
			if eventPlayer.option in eventPlayer.heroesOwned:
				eventPlayer.hero = eventPlayer.option
				eventPlayer.startForcingHero(heroNames[eventPlayer.option])
			else:
				if eventPlayer.blorbux >= heroPrices[eventPlayer.option]:
					eventPlayer.blorbux -= heroPrices[eventPlayer.option]
					eventPlayer.heroesOwned.append(eventPlayer.option)
					smallMessage(eventPlayer, "purchase successful.")
				else:
					smallMessage(eventPlayer, "insufficient funds.")
					eventPlayer.menuState = MENU.BUYBLORBO
			break
		case MENU.LOSE:
			if eventPlayer.option == 0:
				eventPlayer.menuState = MENU.OFF
				eventPlayer.state = STATE.AD
			elif eventPlayer.option == 1:
				eventPlayer.menuState = MENU.MAIN
			break
		case MENU.WIN:
			eventPlayer.credits += 100
			eventPlayer.menuState = MENU.OFF
	# eventPlayer.option = 0
	wait()
	eventPlayer.option = min(eventPlayer.option, menuMaxes[eventPlayer.menuState])

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

### bot mgmt
rule "cheek init & cheek loop":
	@Event eachPlayer
	@Condition eventPlayer.isDummy() == false or eventPlayer.getCurrentHero() == Hero.ORISA
	# @Hero orisa

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
	if eventPlayer.isDummy():
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
	if eventPlayer.isDummy():
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

rule "debug 3rd person":
	@Event eachPlayer
	@Condition eventPlayer.isHoldingButton(Button.MELEE)
	eventPlayer.stopCamera()
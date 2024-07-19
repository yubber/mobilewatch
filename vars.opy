#!mainFile "assrun.opy"
playervar lcheek
playervar rcheek
playervar asssize
playervar is3p
playervar walkDuration # is bbl taker
playervar state
playervar menuState
playervar temp # for gen
playervar i
playervar bots
playervar next
playervar opp # for dummies, is owner id

playervar credits
playervar owcoins
playervar kotix
playervar blorbux

playervar option
playervar visopt

enum STATE:
	MENU,
	GAME,
	AD

enum MENU:
	OFF,
	MAIN,
	SHOP,
	CURRENCY,
	BUYCOIN,
	BUYKOTICK,
	BUYBLORBO,
	SKINS,
	PANTS,
	HEROES,
	LOSE,
	WIN

globalvar bblGivers = [Hero.MERCY, Hero.SOLDIER, Hero.BAPTISTE, Hero.ANA, Hero.LIFEWEAVER]
globalvar bblTakers = [Hero.WIDOWMAKER, Hero.MOIRA, Hero.JUNKER_QUEEN, Hero.SIGMA]
globalvar i

# effect on character
globalvar coinValues = [500,1000,2200,5700,11600]
globalvar coinPrices = [7,14,28,70,140]
# kotickets -> fancy skin, effect on ass
globalvar kotickValues = [10, 30, 50, 100]
globalvar kotickPrices = [14, 37, 56, 105]
# blorbo: different hero
globalvar blorboValues = [100,200,400,900]
globalvar blorboPrices = [8.4, 16.8, 33.6, 67.2]

# idea: have the horse tp to the shop page
globalvar skinNames = ["classic", "overcharged", "clouds", "fortified", "digital"]
globalvar skinPrices = [0, 1400, 1100, 5900, 6900]
playervar skinsOwned = [0]
playervar skin = 0

globalvar pantNames = ["default", "overcharged", "mist", "digital", "hotcakes"]
globalvar pantPrices = [0, 200, 150, 500, 1000]
playervar pantsOwned = [0]
playervar pants = 0

globalvar heroNames = [Hero.ORISA, Hero.ROADHOG, Hero.BASTION, Hero.ZENYATTA, Hero.WINSTON]
globalvar heroPrices = [0, 1000, 1100, 800, 9999]
playervar heroesOwned = [0]
playervar hero = 0

globalvar menuLook = vect(148.9, 7.21, -79.72)
globalvar menuCam = vect(149.23, 7, -78.72)
globalvar menuMaxes = [0, 2, 4, 3, len(coinValues), len(kotickValues), len(blorboValues), len(skinNames), len(pantNames), len(heroNames), 2, 1]

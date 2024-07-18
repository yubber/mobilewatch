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
	BUYCOIN,
	BUYKOTICK,
	BUYBLORBO,
	LOSE,
	WIN

globalvar bblGivers = [Hero.MERCY, Hero.SOLDIER, Hero.BAPTISTE, Hero.ANA, Hero.LIFEWEAVER]
globalvar bblTakers = [Hero.WIDOWMAKER, Hero.MOIRA, Hero.JUNKER_QUEEN, Hero.SIGMA]
globalvar i

globalvar coinValues = [500,1000,2200,5700,11600]
globalvar coinPrices = [7,14,28,70,140]
# kotickets -> fancy skin
globalvar kotickValues = [10, 30, 50, 100]
globalvar kotickPrices = [14, 37, 56, 105]

globalvar blorboValues = [100,200,400,900]
globalvar blorboPrices = [8.4, 16.8, 33.6, 67.2]

globalvar menuLook = vect(148.9, 7.21, -79.72)
globalvar menuCam = vect(149.23, 7, -78.72)
globalvar menuMaxes = [0, 2, 3, len(coinValues), len(kotickValues), len(blorboValues), 2, 1]

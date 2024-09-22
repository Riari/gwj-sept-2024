extends Node

signal achievement_unlocked(title: String, description: String)

var cats_spawned = 0
var cats_height_reached = 0
var tower_height = 0

const CATS_SPAWNED_ACHIEVEMENTS = {
	1: { "title": "First arrival", "description": "Attract your first guest." },
	10: { "title": "Ten cats", "description": "Attract ten guests." },
	50: { "title": "Full house", "description": "Reach the maximum guest limit." },
}

const CATS_HEIGHT_REACHED_ACHIEVEMENTS = {
	5: { "title": "Definitely a tower", "description": "A guest reached the fifth level of your tower." },
	20: { "title": "It's quiet up here", "description": "A guest reached the twentieth level of your tower." },
	50: { "title": "The moon is made of cheese", "description": "A guest has climbed your tower and reached the stars." }
}

const TOWER_HEIGHT_ACHIEVEMENTS = {
	5: { "title": "Level 5", "description": "Your tower has reached a height of five levels." },
	20: { "title": "Level 20", "description": "Your tower has reached a height of twenty levels." },
	50: { "title": "Spacious", "description": "Your tower has reached maximum height." }
}

func unlock_achievement(achievement: Dictionary) -> void:
	achievement_unlocked.emit(achievement["title"], achievement["description"])

func on_cat_spawned() -> void:
	cats_spawned += 1
	if CATS_SPAWNED_ACHIEVEMENTS.has(cats_spawned):
		unlock_achievement(CATS_SPAWNED_ACHIEVEMENTS[cats_spawned])

func on_cat_reached_level(level: int) -> void:
	if level > cats_height_reached:
		cats_height_reached = level
		if CATS_HEIGHT_REACHED_ACHIEVEMENTS.has(level):
			unlock_achievement(CATS_HEIGHT_REACHED_ACHIEVEMENTS[level])

func on_tower_reached_level(level: int) -> void:
	if level > tower_height:
		tower_height = level
		if TOWER_HEIGHT_ACHIEVEMENTS.has(level):
			unlock_achievement(TOWER_HEIGHT_ACHIEVEMENTS[level])
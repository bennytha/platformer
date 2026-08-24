class_name GameConstants
extends RefCounted

enum GameType {
	LEVEL,
	MAP,
	DEMO
}

const PLAYER_LAYER: int = 1 << 0
const WORLD_LAYER: int = 1 << 1
const DAMAGE_PLAYER_LAYER: int = 1 << 2
const PLAYER_INTERACTION_LAYER: int = 1	<< 3
const NON_PLAYER_INTERACTION_LAYER: int = 1 << 4

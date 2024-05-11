extends CharacterBody2D

@export var patrolSpeed : float = 300.0
@export var chaseSpeed : float = 350.0

@onready var nav : NavigationAgent2D = $NavigationAgent2D



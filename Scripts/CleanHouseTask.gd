extends Node3D

@onready var quest_control = $"../QuestControl"
@onready var player_dialogue = $"../Player/DialogueText"
@onready var interact_text = $"../InteractText/InteractText"

@onready var toilet = %House/Bathroom2/Toilet
@onready var clean_sodas = $CleanSodas/CleanSodas/CleanSodas
@onready var clean_pizza = $CleanPizza/CleanPizza/CleanPizza
@onready var clean_living_room_plates = $CleanLivingRoomPlates/CleanLivingRoomPlates/CleanLivingRoomPlates
@onready var clean_kitchen_plates = $CleanKitchenPlates/CleanKitchenPlates/CleanKitchenPlates
@onready var clean_cereal = $CleanCereal/CleanCereal/CleanCereal
@onready var clean_toilet = $CleanToilet/CleanToilet/CleanToilet
@onready var trash = $TrashCan/TrashCan/Trash

var questEnabled = false
var canClean = false
var currentNode
var toClean = 6
var canThrowAway = false
var cleanedToilet = false

func _process(delta):
	if (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("LeftMouseButton")) and canClean and IsRayCasting.canInteract:
		if currentNode == "CleanToilet":
			toilet.cleanToilet()
			cleanedToilet = true
		get_node(currentNode).queue_free()
		toClean -= 1
		
		if toClean == 1 and !cleanedToilet:
			player_dialogue.queueDialogue("não posso me esquecer do vaso.")
			player_dialogue.showDialogue()
		if toClean == 0:
			await get_tree().create_timer(1.5).timeout
			player_dialogue.queueDialogue("acho que terminei, preciso jogar isso fora no lixo da cozinha.")
			player_dialogue.showDialogue()
			trash.set_deferred("disabled", false) 
	
	if (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("LeftMouseButton")) and canThrowAway and IsRayCasting.canInteract:
		quest_control.finishQuest()
		self.queue_free()

func activateCollisions():
	clean_sodas.set_deferred("disabled", false)
	clean_pizza.set_deferred("disabled", false)
	clean_living_room_plates.set_deferred("disabled", false)
	clean_kitchen_plates.set_deferred("disabled", false)
	clean_cereal.set_deferred("disabled", false)
	clean_toilet.set_deferred("disabled", false)

func _on_clean_entered(body, node_name):
	interact_text.text = "[E] Limpar"
	interact_text.show()
	canClean = true
	currentNode = node_name

func _on_clean_exited(body):
	interact_text.hide()
	canClean = false

func _on_trash_can_body_entered(body):
	interact_text.text = "[E] Jogar Fora"
	interact_text.show()
	canThrowAway = true

func _on_trash_can_body_exited(body):
	interact_text.hide()
	canThrowAway = false

func _on_trigger_task_body_entered(body):
	if quest_control.questActive == 6:
		get_node("TriggerTask").queue_free()
		activateCollisions()
		quest_control.startQuest()
		player_dialogue.timeBetweenText = 3
		player_dialogue.queueDialogue("essa casa ta uma bagunça, parece que quem estava aqui saiu as pressas")
		player_dialogue.queueDialogue("preciso limpar isso")
		player_dialogue.showDialogue()

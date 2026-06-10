extends Node2D

# Strain Menu script.

@onready
var virus_buttons : Array[Button] = [
	$CanvasLayer/UI/Virus1Button,
	$CanvasLayer/UI/Virus2Button,
	$CanvasLayer/UI/Virus3Button,
	$CanvasLayer/UI/Virus4Button,
	$CanvasLayer/UI/Virus5Button,
]

@onready
var control_buttons : Array[Button] = [
	%SynthesizeButton,
	%RecombineButton,
	%UpgradeButton,
	%RecycleButton
]

var current_virus_button : Button = null
var current_button : Button = null

func _ready() -> void:
	get_viewport().gui_focus_changed.connect(_on_viewport_gui_focus_changed)
	#for button in virus_buttons:
		#var strain : Strain = Strain.get_random_strain()
		#GameManager.state.strains.push_back(strain)
		#button.get_node("TextureRect").modulate = strain.color
		#button.text = strain.name
	$CanvasLayer/UI/Virus1Button.grab_focus()

func _process(delta: float) -> void:
	# Update virus buttons
	for i in virus_buttons.size():
		var strain : Strain = GameManager.state.strains[i]
		if strain:
			virus_buttons[i].text = strain.name
			virus_buttons[i].get_node("TextureRect").modulate = strain.color
		else:
			virus_buttons[i].text = "EMPTY SLOT"
			virus_buttons[i].get_node("TextureRect").modulate = Color.WHITE
	
	# Update currency
	%RNALabel.text = "RNA %s" % str(GameManager.state.rna).pad_zeros(5)
	%DNALabel.text = "DNA %s" % str(GameManager.state.dna).pad_zeros(5)
	
	# Update virus info
	var strain : Strain = GameManager.state.strains[virus_buttons.find(current_virus_button)]
	if not strain:
		$CanvasLayer/UI/StrainInfoControl/NameLabel.text = "EMPTY VIRUS SLOT"
		$CanvasLayer/UI/StrainInfoControl/PositiveEffectLabel.text = ""
		$CanvasLayer/UI/StrainInfoControl/NegativeEffectLabel.text = ""
	else:
		$CanvasLayer/UI/StrainInfoControl/NameLabel.text = strain.name
		$CanvasLayer/UI/StrainInfoControl/PositiveEffectLabel.text = Strain.get_description(strain.positive_effect, strain.potency)
		$CanvasLayer/UI/StrainInfoControl/NegativeEffectLabel.text = Strain.get_description(strain.negative_effect, strain.potency, false)

func _on_viewport_gui_focus_changed(node : Control):
	if node is not Button:
		current_button.grab_focus()
		return
	elif node is Button and node.disabled:
		current_button.grab_focus()
		return
	
	if current_button != null:
		$SelectSound.play()
	
	current_button = node
	
	if node in virus_buttons:
		current_virus_button = node
		%ActionInfoLabel.text = "PRESS Z TO CHOOSE AN ACTION FOR THIS STRAIN."
	
	elif node in control_buttons:
		var strain : Strain = GameManager.state.strains[virus_buttons.find(current_virus_button)]
		if strain:
			%SynthesizeButton.disabled = true
			%RecombineButton.disabled = false
			%UpgradeButton.disabled = false
			%RecycleButton.disabled = false
		else:
			%SynthesizeButton.disabled = false
			%RecombineButton.disabled = true
			%UpgradeButton.disabled = true
			%RecycleButton.disabled = true
		
		if node == %SynthesizeButton:
			%ActionInfoLabel.text = "SYNTHESIZE A RANDOM STRAIN.\n  COST: %d RNA" % Strain.SYNTHESIZE_COST
		elif node == %RecombineButton:
			%ActionInfoLabel.text = "RECOMBINE THIS STRAIN. ITS POTENCY WILL CHANGE RANDOMLY. CAN ALSO ERASE AN EFFECT.\n  COST: %d RNA" % strain.get_recombination_cost() 
		elif node == %UpgradeButton:
			%ActionInfoLabel.text = "INCREASE THE POTENCY OF THE VIRUS. WILL NEVER ERASE AN EFFECT.\n  COST: %d RNA %d DNA" % [strain.get_upgrade_rna_cost(), strain.get_upgrade_dna_cost()]
		elif node == %RecycleButton:
			%ActionInfoLabel.text = "DESTROY THE SELECTED STRAIN.\nYOU WILL GET %d RNA BACK." % strain.get_recycle_amount()
		
	
	elif node == %MissionStartButton:
		%ActionInfoLabel.text = "SAVE THE GALAXY!"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Accept"):
		if current_button in virus_buttons:
			for button in control_buttons:
				button.show()
			var strain : Strain = GameManager.state.strains[virus_buttons.find(current_virus_button)]
			if not strain:
				%SynthesizeButton.disabled = false
				%RecombineButton.disabled = true
				%UpgradeButton.disabled = true
				%RecycleButton.disabled = true
				%SynthesizeButton.grab_focus()
			else:
				%SynthesizeButton.disabled = true
				%RecombineButton.disabled = false
				%UpgradeButton.disabled = false
				%RecycleButton.disabled = false
				%UpgradeButton.grab_focus()
		elif current_button in control_buttons:
			if current_button.disabled:
				return
			
			var current_strain : Strain = GameManager.state.strains[virus_buttons.find(current_virus_button)]
			if current_button == %SynthesizeButton:
				if GameManager.state.rna < Strain.SYNTHESIZE_COST:
					%ActionInfoLabel.text = "INSUFFICIENT CURRENCY."
				else:
					$SynthesizeSound.play()
					GameManager.add_rna(-Strain.SYNTHESIZE_COST)
					GameManager.state.strains[virus_buttons.find(current_virus_button)] = Strain.get_random_strain()
					%SynthesizeButton.disabled = true
					%RecombineButton.disabled = false
					%UpgradeButton.disabled = false
					%RecycleButton.disabled = false
					%UpgradeButton.grab_focus()
			elif current_button == %RecombineButton:
				if current_strain.get_recombination_cost() > GameManager.state.rna:
					%ActionInfoLabel.text = "INSUFFICIENT CURRENCY."
				else:
					$UpgradeSound.play()
					GameManager.add_rna(-current_strain.get_recombination_cost())
					current_strain.recombine()
					%ActionInfoLabel.text = "RECOMBINE THIS STRAIN. ITS POTENCY WILL CHANGE RANDOMLY. CAN ALSO ERASE AN EFFECT.\n  COST: %d RNA" % current_strain.get_recombination_cost() 
			elif current_button == %UpgradeButton:
				if current_strain.get_upgrade_rna_cost() > GameManager.state.rna or current_strain.get_upgrade_dna_cost() > GameManager.state.dna:
					%ActionInfoLabel.text = "INSUFFICIENT CURRENCY."
				elif current_strain.potency == 1.0:
					%ActionInfoLabel.text = "THIS STRAIN CANNOT BE UPGRADED ANY FURTHER."
				else:
					$UpgradeSound.play()
					GameManager.add_rna(-current_strain.get_upgrade_rna_cost())
					GameManager.add_dna(-current_strain.get_upgrade_dna_cost())
					current_strain.upgrade()
					%ActionInfoLabel.text = "INCREASE THE POTENCY OF THE VIRUS. WILL NEVER ERASE AN EFFECT.\n  COST: %d RNA %d DNA" % [current_strain.get_upgrade_rna_cost(), current_strain.get_upgrade_dna_cost()]
			elif current_button == %RecycleButton:
				$RecycleSound.play()
				GameManager.add_rna(current_strain.get_recycle_amount())
				GameManager.state.strains[virus_buttons.find(current_virus_button)] = null
				%SynthesizeButton.disabled = false
				%RecombineButton.disabled = true
				%UpgradeButton.disabled = true
				%RecycleButton.disabled = true
				%SynthesizeButton.grab_focus()
		elif current_button == %MissionStartButton:
			$AcceptSound.play()
			GameManager.change_level(load("res://Scenes/Levels/Test/TestLevel.tscn"))
	
	elif event.is_action_pressed("Cancel"):
		if current_button in control_buttons:
			for button in control_buttons:
				button.hide()
			
			current_virus_button.grab_focus()

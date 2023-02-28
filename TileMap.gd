extends TileMap

var TILE = {
	CHAO = Vector2(0,0),
	COBRA = Vector2(1,0),
	COMIDA = Vector2(0,1)
}

const INICIO = Vector2(10,10)
const MAPA_TAMANHO = Vector2(20,20)

var cobra = []
var comidas = []
var tamanho = 3

var next_direction = Vector2(1,0)
var actual_direction = Vector2(1,0)

func _ready():
	for cell in tamanho:
		cobra.append(Vector2(INICIO.x - cell, INICIO.y))
	draw()
	spawn_food()

func _process(delta):
	input()

func _on_timer_timeout():
	move()
	check()
	draw()

func move():
	actual_direction = next_direction
	var cell = cobra[0]
	var last = Vector2(cell)
	var new_cell = cell + actual_direction
	new_cell = saiu_da_janela(new_cell)
	cobra[0] = new_cell
	for i in range(1,len(cobra)):
		cell = cobra[i]
		var copy = Vector2(cell)
		cobra[i] = last
		last = copy

func input():
	var new_direction = Vector2(Input.get_axis("left","right"), Input.get_axis("up","down"))
	
	if new_direction == Vector2.ZERO: return
	if new_direction == actual_direction * -1: return
	if new_direction.length() > 1: return 
	
	next_direction = new_direction

func check():
	for cell in cobra:
		if cobra.count(cell) > 1:
			$Timer.stop() # morreu
			$morte.show()
			return

	if comidas.has(cobra[0]):
		cobra.append(Vector2(cobra[-1]))
		comidas.pop_back()
		spawn_food()

func criar_posicao_pra_comida_yum_yum():
	return Vector2(randi_range(0, MAPA_TAMANHO.x-1), randi_range(0, MAPA_TAMANHO.y-1))

func saiu_da_janela(vector):
	var tela = Rect2i(Vector2.ZERO, MAPA_TAMANHO)

	return Vector2(
		int(vector.x + MAPA_TAMANHO.x) % int(MAPA_TAMANHO.x), 
		int(vector.y + MAPA_TAMANHO.y) % int(MAPA_TAMANHO.y)
	)

func spawn_food():
	var food = criar_posicao_pra_comida_yum_yum()
	
	while cobra.has(food):
		food = criar_posicao_pra_comida_yum_yum()
	
	comidas.append(food)

func draw():
	for x in MAPA_TAMANHO.x:
		for y in MAPA_TAMANHO.y:
			if cobra.has(Vector2(x,y)):
				set_cell(0,Vector2(x,y),0,TILE.COBRA)
				
			elif comidas.has(Vector2(x,y)):
				set_cell(0,Vector2(x,y),0,TILE.COMIDA)
				
			else:
				set_cell(0,Vector2(x,y),0,TILE.CHAO)

func _on_button_pressed():
	get_tree().reload_current_scene()

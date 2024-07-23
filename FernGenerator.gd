@tool
extends EditorScript

# Overall Gen
const NUM_BUSHES = 10

# Bush Gen
const MIN_NUM_LEAVES = 9; const MAX_NUM_LEAVES = 12

# Leaf Gen
const MIN_SIZE_MOD = 0.6; const MAX_SIZE_MOD = 1.2;
const MAX_COLOR_ADJUSTMENT = 0.15;
const MIN_WIDTH = 3.0; const MAX_WIDTH = 3.75;
const MIN_NUM_SEGMENTS = 8; const MAX_NUM_SEGMENTS = 12;
const EXTRA_TALL_CHANCE = 0.025
const MIN_SEGMENT_LENGTH = 3.5; const MAX_SEGMENT_LENGTH = 5.5;
const MIN_EXTRA_TALL_MOD = 1.25; const MAX_EXTRA_TALL_MOD = 1.6;
const MAX_POSITION_OFFSET = 2.0;
const ANGLE_D1_MAX = PI/16; const ANGLE_D2_MAX = PI/64;

var leafScene : PackedScene = load("res://leaf.tscn")
var leafParent : Node2D

# Called when the script is executed (using File -> Run in Script Editor).
func _run():
	leafParent = get_scene().find_child("LeafParent")
	for child in leafParent.get_children():
		child.free()
	
	for i in NUM_BUSHES:
		GenerateBush(leafParent.global_position + (Vector2.RIGHT * i * 8.0))

func GenerateBush(startingPosition : Vector2):
	var bushParent : Node2D = Node2D.new()
	leafParent.add_child(bushParent, true)
	leafParent.move_child(bushParent, randi_range(0, leafParent.get_child_count() - 1)) # randomly order
	bushParent.owner = get_scene()
	
	var numLeaves = randi_range(MIN_NUM_LEAVES, MAX_NUM_LEAVES)
	# todo make width never less than 0
	
	# randomize overall size
	var sizeMod: float = randf_range(MIN_SIZE_MOD, MAX_SIZE_MOD)
	# randomize gradient
	var maximum = 1.0 + MAX_COLOR_ADJUSTMENT
	var minimum = 1.0 - MAX_COLOR_ADJUSTMENT
	var colorAdjustment : Color = Color(randf_range(minimum, maximum), randf_range(minimum, maximum), randf_range(minimum, maximum), 1.0)
	for n in numLeaves:
		# randomize segments, length, width
		
		# add "wild leaves", and randomly longer leaves
		var leaf : Line2D = GenerateLeaf(bushParent)
		leaf.width = randf_range(MIN_WIDTH, MAX_WIDTH) * sizeMod
		leaf.width_curve = leaf.width_curve.duplicate(true)
		leaf.gradient = leaf.gradient.duplicate(true)
		for point in leaf.gradient.get_point_count():
			leaf.gradient.set_color(point, leaf.gradient.get_color(point) * colorAdjustment)
		
		var numSegments = randi_range(MIN_NUM_SEGMENTS, MAX_NUM_SEGMENTS)
		var segmentLength = randf_range(MIN_SEGMENT_LENGTH, MAX_SEGMENT_LENGTH) * sizeMod
		if (randf() < EXTRA_TALL_CHANCE): # extra tall
			segmentLength *= randf_range(MIN_EXTRA_TALL_MOD, MAX_EXTRA_TALL_MOD)
		
		var position : Vector2 = startingPosition + Vector2(randf_range(-MAX_POSITION_OFFSET, MAX_POSITION_OFFSET), randf_range(-MAX_POSITION_OFFSET, MAX_POSITION_OFFSET))
		
		var points : PackedVector2Array = [position]
		var angle : float = PI/2
		var angleD1 : float = randf_range(-ANGLE_D1_MAX, ANGLE_D1_MAX)
		var angleD2 : float = randf_range(-ANGLE_D2_MAX, ANGLE_D2_MAX)
		if (randf() > 0.95): # wild
			var sign: int = sign(angleD2)
			angleD1 = randf_range(ANGLE_D2_MAX/2, ANGLE_D2_MAX) * sign * 3.0
			angleD2 = -angleD1 * .4
		
		for segment in numSegments:
			position += Vector2(cos(angle), -sin(angle)) * segmentLength
			angle += angleD1
			angleD1 += angleD2
			
			points.append(position)
		
		leaf.points = points

func GenerateLeaf(parent : Node2D = leafParent) -> Line2D:
	var leaf = leafScene.instantiate()
	parent.add_child(leaf);
	leaf.owner = get_scene()
	return leaf

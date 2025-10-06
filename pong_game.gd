extends Node2D

# 球的移动速度
var ball_speed = 300
# 球的移动方向 (1,1)表示向右下移动
var ball_direction = Vector2(1, 1)

# 球拍移动速度
var paddle_speed = 300

# 玩家得分
var player1_score = 0
var player2_score = 0

# 通过节点路径引用Label节点，这样我们就能在代码中修改它的文本
@onready var score_label = $HUD/ScoreLabel

# 当节点进入场景树时调用
func _ready():
	# 初始化随机数生成器，让球有随机初始方向
	randomize()
	# 设置球的初始随机方向
	ball_direction = Vector2(1, randf() * 2 - 1).normalized()
	# 游戏启动时初始化分数显示
	update_score_display()  


	

# 每一帧调用
func _process(delta):
	# 移动球
	move_ball(delta)
	
	# 移动AI球拍（右球拍）
	move_ai_paddle(delta)
	
	# 检测玩家输入（左球拍）
	handle_player_input(delta)
	
	# 检测得分
	check_score()

# 移动球
func move_ball(delta):
	# 计算球的新位置
	$Ball.position += ball_direction * ball_speed * delta
	
	# 检测球与上下边界的碰撞
	if $Ball.position.y <= 0 or $Ball.position.y >= 600 - $Ball.size.y:
		ball_direction.y = -ball_direction.y  # 反转Y方向
	
	# 检测球与球拍的碰撞
	if ($Ball.position.x <= $LeftPaddle.position.x + $LeftPaddle.size.x and
		$Ball.position.x >= $LeftPaddle.position.x and
		$Ball.position.y + $Ball.size.y >= $LeftPaddle.position.y and
		$Ball.position.y <= $LeftPaddle.position.y + $LeftPaddle.size.y):
		
		# 球击中左球拍，改变方向
		ball_direction.x = abs(ball_direction.x)  # 确保向右移动
		# 根据击中球拍的位置改变反弹角度
		var hit_pos = ($Ball.position.y - $LeftPaddle.position.y) / $LeftPaddle.size.y
		ball_direction.y = (hit_pos - 0.5) * 2
	
	if ($Ball.position.x + $Ball.size.x >= $RightPaddle.position.x and
		$Ball.position.x <= $RightPaddle.position.x + $RightPaddle.size.x and
		$Ball.position.y + $Ball.size.y >= $RightPaddle.position.y and
		$Ball.position.y <= $RightPaddle.position.y + $RightPaddle.size.y):
		
		# 球击中右球拍，改变方向
		ball_direction.x = -abs(ball_direction.x)  # 确保向左移动
		# 根据击中球拍的位置改变反弹角度
		var hit_pos = ($Ball.position.y - $RightPaddle.position.y) / $RightPaddle.size.y
		ball_direction.y = (hit_pos - 0.5) * 2
	
	# 确保方向向量是单位向量（长度为1）
	ball_direction = ball_direction.normalized()

# 移动AI球拍（简单的AI）
func move_ai_paddle(delta):
	# 如果球在AI一侧且朝AI移动
	if ball_direction.x > 0:
		# 计算球与AI球拍中心的垂直距离
		var ball_center = $Ball.position.y + $Ball.size.y / 2
		var paddle_center = $RightPaddle.position.y + $RightPaddle.size.y / 2
		
		# 根据球的位置移动AI球拍
		if ball_center < paddle_center - 10:
			$RightPaddle.position.y -= paddle_speed * delta
		elif ball_center > paddle_center + 10:
			$RightPaddle.position.y += paddle_speed * delta
		
		# 确保AI球拍不超出屏幕
		$RightPaddle.position.y = clamp($RightPaddle.position.y, 0, 600 - $RightPaddle.size.y)

# 处理玩家输入
func handle_player_input(delta):
	# 检测按键输入
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		$LeftPaddle.position.y -= paddle_speed * delta
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		$LeftPaddle.position.y += paddle_speed * delta
	
	# 确保玩家球拍不超出屏幕
	$LeftPaddle.position.y = clamp($LeftPaddle.position.y, 0, 600 - $LeftPaddle.size.y)

# 检测得分
func check_score():
	# 球出左边界 - 玩家2得分
	if $Ball.position.x < 0:
		player2_score += 1
		reset_ball(-1)  # 重置球，方向向左
		update_score_display()
	
	# 球出右边界 - 玩家1得分
	if $Ball.position.x > 800:
		player1_score += 1
		reset_ball(1)   # 重置球，方向向右
		update_score_display()
	
	# 打印得分（后续可以添加UI显示）
	if player1_score > 0 or player2_score > 0:
		print("玩家1: ", player1_score, " - 玩家2: ", player2_score)

func update_score_display():
	# 设置Label的text属性，从而改变屏幕上显示的文字
	score_label.text = "YOU: %s - CPU: %s" % [player1_score, player2_score]

# 重置球的位置和方向
func reset_ball(direction_x):
	# 将球放回屏幕中央
	$Ball.position = Vector2(390, 290)
	
	# 设置新的随机方向
	ball_direction = Vector2(direction_x, randf() * 2 - 1).normalized()

-- init scene config
import(".config.role_define")
import(".config.config_scene")

-- init scenes
import(".scenes.base_scene")
import(".scenes.game_start_scene.game_start_scene")
import(".scenes.battle_scene.battle_scene")

-- 在最后
import(".scenes.scene_manager")

class AddDefaultValuesToGameboard < ActiveRecord::Migration[6.1]
  def up
    change_column_default :gameboards, :current_state, "awaiting_player"
    change_column_default :gameboards, :player_atk, 0
    change_column_default :gameboards, :monster_atk, 0
    change_column_default :gameboards, :asked_help, false
    change_column_default :gameboards, :success, false
    change_column_default :gameboards, :can_flee, false
    change_column_default :gameboards, :shared_reward, 0
  end

  def down
    change_column_default :gameboards, :current_state, nil
    change_column_default :gameboards, :player_atk, nil
    change_column_default :gameboards, :monster_atk, nil
    change_column_default :gameboards, :asked_help, nil
    change_column_default :gameboards, :success, nil
    change_column_default :gameboards, :can_flee, nil
    change_column_default :gameboards, :shared_reward, nil
  end
end

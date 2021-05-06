# frozen_string_literal: true

class Gameboard < ApplicationRecord
  has_many :players, dependent: :destroy
  has_many :ingamedeck, dependent: :destroy
  # has_one :player, foreign_key: 'current_player'
  belongs_to :current_player, class_name: 'Player', foreign_key: 'player_id', optional: true
  belongs_to :helping_player, class_name: 'Player', foreign_key: 'helping_player_id', optional: true
  has_one :centercard, dependent: :destroy
  has_one :graveyard, dependent: :destroy
  has_one :interceptcard, dependent: :destroy
  has_one :playerinterceptcard, dependent: :destroy
  enum current_state: %i[lobby ingame intercept_phase intercept_finished game_won boss_phase boss_phase_finished]

  # has_many :cards, through: :ingame_cards

  def initialize_game_board
    current_player = players.last
    gameboard_id = id
    update(current_player: current_player, current_state: 'ingame')
    Centercard.find_or_create_by!(gameboard_id: gameboard_id)
    Graveyard.find_or_create_by!(gameboard_id: gameboard_id)
    Playerinterceptcard.find_or_create_by!(gameboard_id: gameboard_id)
    Interceptcard.find_or_create_by!(gameboard_id: gameboard_id)

    # pp Player.find(current_player).gameboard
    players.each do |player|
      lobby_card = 0
      player.user.monsterone.blank? ? nil : lobby_card += 1
      player.user.monstertwo.blank? ? nil : lobby_card += 1
      player.user.monsterthree.blank? ? nil : lobby_card += 1
      Handcard.find_or_create_by!(player_id: player.id) # unless player.handcard
      Handcard.draw_handcards(player.id, self, 4) unless  lobby_card.positive?
      Handcard.draw_handcards(player.id, self, 5 - lobby_card) if lobby_card.positive?
      Handcard.draw_one_monster(player.id, self) unless lobby_card.positive?
    end
  end

  def self.broadcast_game_board(gameboard)
    players_array = []

    gameboard = Gameboard.find(gameboard.id)

    gameboard.players.order(:id).each do |player|
      players_array.push(player.reload.render_player)
    end

    {
      # graveyard: gameboard.graveyard,
      players: players_array,
      gameboard: render_gameboard(gameboard)
    }
  end

  # render cards for frontend
  def self.render_cards_array(cards)
    card_array = []

    # return nil if cards are empty
    return nil unless cards

    cards.each do |card|
      card_array.push({ unique_card_id: card.id, card_id: card.card_id })
    end

    card_array
  end

  def self.render_user_monsters(player, monsterslot)
    monster = case monsterslot
              when 'Monsterone'
                player.monsterone
              when 'Monstertwo'
                player.monstertwo
              else
                player.monsterthree
              end

    items = []

    output = []

    # pp monster.ingamedecks
    if monster.ingamedecks.count.positive?

      unique_monster_id = monster.ingamedecks[0].id
      monster_id = monster.ingamedecks[0].card_id

      monster.ingamedecks.each do |ingamedeck|
        if ingamedeck.card.type == 'Monstercard'
          unique_monster_id = ingamedeck.id
          monster_id = ingamedeck.card_id

        else
          items.push({ unique_card_id: ingamedeck.id, card_id: ingamedeck.card_id })
        end
      end

      output = {
        unique_card_id: unique_monster_id,
        card_id: monster_id,
        item: items
      }
    end
    output
  end

  def self.render_card_from_id(id)
    card = Ingamedeck.find_by!('id = ?', id)
    { unique_card_id: card.id, card_id: card.card_id }
  end

  def self.render_gameboard(gameboard)
    atk_points = calc_attack_points(gameboard.reload)

    centercard = (render_card_from_id(gameboard.centercard.ingamedeck.id) if gameboard.centercard.ingamedeck)
    {
      gameboard_id: gameboard.id,
      current_player: gameboard.current_player&.id,
      center_card: centercard,
      interceptcards: render_cards_array(gameboard.interceptcard&.ingamedecks),
      player_interceptcards: render_cards_array(gameboard.playerinterceptcard&.ingamedecks),
      player_atk: atk_points[:playeratk],
      monster_atk: atk_points[:monsteratk],
      success: gameboard.success,
      can_flee: gameboard.can_flee,
      intercept_timestamp: gameboard.intercept_timestamp,
      current_state: gameboard.current_state,
      rewards_treasure: gameboard.rewards_treasure,
      graveyard: render_cards_array(gameboard.graveyard.ingamedecks),
      shared_reward: gameboard.shared_reward,
      helping_player: gameboard.helping_player&.id,
      player_element_synergy_modifiers: gameboard.player_element_synergy_modifiers,
      monster_element_synergy_modifiers: gameboard.monster_element_synergy_modifiers
    }
  end

  def self.get_next_player(gameboard)
    gameboard = Gameboard.find_by('id = ?', gameboard.id)
    players = gameboard.players.order(:id)
    current_player_id = gameboard.current_player.id

    gameboard.current_player.reload.playercurse.ingamedecks.each do |ingamedeck|
      ingamedeck.update(cardable: gameboard.graveyard) unless ingamedeck.card.action == 'lose_atk_points'
    end

    # search for the index player with this index
    index_of_player = players.find_index { |player| player.id == current_player_id }

    count = players.count
    # if index is bigger than player count start with first player
    index_of_next_player = (index_of_player + 1) % count

    # get the next Player from array of players
    next_player = players[index_of_next_player]

    gameboard.update(asked_help: false, helping_player: nil, helping_player_atk: 0, shared_reward: 0)

    # save it to gameboard
    gameboard.current_player = next_player
    gameboard.save!

    next_player
  end

  def self.draw_door_card(gameboard)
    # cursecards = Cursecard.all
    monstercards = Monstercard.all
    bosscards = Bosscard.all

    allcards = []
    # addCardsToArray(allcards, cursecards)
    add_cards_to_array(allcards, monstercards)
    add_cards_to_array(allcards, bosscards)

    randomcard = allcards[rand(allcards.size)]

    centercard = Centercard.find_by!('gameboard_id = ?', gameboard.id)

    # centercard.ingamedecks.each do |ingamedeck|
    #   ingamedeck.update!(cardable: gameboard.graveyard)
    # end

    centercard.ingamedeck&.update!(cardable: gameboard.graveyard)

    # centercard
    Ingamedeck.create(gameboard: gameboard, card_id: randomcard, cardable: centercard)

    new_center = Centercard.find_by('gameboard_id = ?', gameboard.id)
    new_treasure = Card.find_by('id = ?', randomcard).rewards_treasure

    gameboard.update(centercard: new_center, rewards_treasure: new_treasure)

    # if bosscard is drawn, phase is boss_phase, otherwise always intercept_phase
    if gameboard.centercard.card.type == 'Bosscard'
      gameboard.boss_phase!
    else
      gameboard.intercept_phase!

    end

    attack_obj = calc_attack_points(gameboard.reload)

    gameboard.update(success: attack_obj[:result], player_atk: attack_obj[:playeratk], monster_atk: attack_obj[:monsteratk])

    gameboard.players.each do |player|
      player.update!(intercept: true)
    end

    gameboard.centercard.card.title
  end

  def self.flee(gameboard, current_user)
    roll = rand(1..6)

    output = {}

    if roll > 4
      gameboard.update!(can_flee: true)
      output = {
        flee: true,
        value: roll,
        player_name: current_user.name
      }
    else
      gameboard.update!(can_flee: false)
      Monstercard.bad_things(gameboard.centercard, gameboard)

      output = {
        flee: false,
        value: roll,
        player_name: current_user.name
      }
    end

    # TODO: add bad things if flee does not succeed
    get_next_player(gameboard)
    clear_buffcards(gameboard)
    output
  end

  def self.calc_attack_points(gameboard)
    gameboard.reload

    boss_phase = gameboard.boss_phase?

    return { result: false, playeratk: 0, monsteratk: 0 } unless gameboard.current_player

    players = boss_phase ? gameboard.players : [gameboard.current_player]

    playeratkpoints = 0
    monsteratkpts = 0

    players.each do |player|
      playeratkpoints += player.calculate_player_atk_with_monster_and_items

      player.playercurse.ingamedecks.each do |curse|
        curse_obj = Cursecard.activate(curse, player, gameboard, playeratkpoints, monsteratkpts)

        playeratkpoints = curse_obj[:playeratk]
        monsteratkpts = curse_obj[:monsteratk]
      end
    end

    ## monsteratk points get set to 0 if cards.first is nil => no centercard
    monsteratkpts += gameboard.centercard.card&.atk_points || 0

    # onlcy calc modifiers when bossphase is false
    unless boss_phase
      monsteratkpts += gameboard.monster_element_synergy_modifiers
      playeratkpoints += gameboard.player_element_synergy_modifiers
    end

    # add helping player atk
    playeratkpoints += gameboard.helping_player_atk

    # #add intercept buffs
    monsteratkpts += gameboard.interceptcard.reload.cards.sum(:atk_points) || 0

    # calc intercept bufs
    playeratkpoints += gameboard.playerinterceptcard.reload.cards.sum(:atk_points) || 0

    result = playeratkpoints > monsteratkpts

    gameboard.update(success: result)

    { result: result, playeratk: playeratkpoints, monsteratk: monsteratkpts }
  end

  def set_player_atk
    update!(player_atk: current_player.attack)
  end

  def self.add_cards_to_array(arr, cards)
    cards.each do |card|
      x = card.draw_chance
      while x.positive?
        arr.push card.id
        x -= 1
      end
    end
  end

  def self.clear_buffcards(gameboard)
    gameboard&.interceptcard&.ingamedecks&.each do |card|
      card.update!(cardable: gameboard.graveyard)
    end

    gameboard&.playerinterceptcard&.ingamedecks&.each do |card|
      card.update!(cardable: gameboard.graveyard)
    end
  end

  def update_recalc_element_synergy_modifer
    # set modifiers to zero if there is no centercard
    if centercard.card.reload.nil?
      update!(monster_element_synergy_modifiers: 0, player_element_synergy_modifiers: 0)
      return
    end
    monster_element_modifier = calculate_monster_element_modifier
    synergy_item_monsters = calc_synergy_monster_and_items

    player_element_synergy_modifiers = monster_element_modifier[:modifier_player] + synergy_item_monsters[:modifier_player]
    monster_element_synergy_modifiers = monster_element_modifier[:modifier_monster] + synergy_item_monsters[:modifier_monster]

    update!(monster_element_synergy_modifiers: monster_element_synergy_modifiers, player_element_synergy_modifiers: player_element_synergy_modifiers)

    { monster_element_synergy_modifiers: monster_element_synergy_modifiers, player_element_synergy_modifiers: player_element_synergy_modifiers }
  end

  private

  def sum_of_cards(player, column, columnvalue, cardtype, sumtype)
    # eg where(bad_against:fire, type=enemy_monster.element).sum(bad_against_value)
    monsterone_sum = player.monsterone.cards.where("#{column}=#{columnvalue} AND type='#{cardtype}'").sum(sumtype)
    monstertwo_sum = player.monstertwo.cards.where("#{column}=#{columnvalue} AND type='#{cardtype}'").sum(sumtype)
    monsterthree_sum = player.monsterthree.cards.where("#{column}=#{columnvalue} AND type='#{cardtype}'").sum(sumtype)

    monsterone_sum + monstertwo_sum + monsterthree_sum
  end

  def self.clear_buffcards(gameboard)
    gameboard&.interceptcard&.ingamedecks&.each do |card|
      card.update!(cardable: gameboard.graveyard)
    end

    gameboard&.playerinterceptcard&.ingamedecks&.each do |card|
      card.update!(cardable: gameboard.graveyard)
    end
  end

  def calc_synergy_monster_and_items
    monstercard = centercard.card

    good_against_sum = sum_of_cards(current_player, 'good_against', monstercard.read_attribute_before_type_cast('element'), 'Itemcard', 'good_against_value')

    bad_against_sum = sum_of_cards(current_player, 'bad_against', monstercard.read_attribute_before_type_cast('element'), 'Itemcard', 'bad_against_value')

    synergy_player_sum = 0
    # calc synergy Values of Player Monster
    synergy_player_sum = sum_of_cards(current_player, 'synergy_type', monstercard.read_attribute_before_type_cast('animal'), 'Monstercard', 'synergy_value') if monstercard.animal

    monsterone_card = current_player.monsterone.cards.find_by('type=?', 'Monstercard')
    monstertwo_card = current_player.monstertwo.cards.find_by('type=?', 'Monstercard')
    monsterthree_card = current_player.monsterthree.cards.find_by('type=?', 'Monstercard')

    # calc synergy Values of Center Monster
    synergy_monster_sum = 0
    if monstercard.synergy_type && (monsterone_card&.animal == monstercard.synergy_type || monstertwo_card&.animal == monstercard.synergy_type || monsterthree_card&.animal == monstercard.synergy_type)
      synergy_monster_sum = monstercard.synergy_value
    end

    { modifier_player: good_against_sum + synergy_player_sum - bad_against_sum, modifier_monster: synergy_monster_sum }
  end

  def calculate_monster_element_modifier
    monstercard = centercard.card

    modifier_player = 0
    modifier_monster = 0

    # modifiers are 0 if there is no centercard
    return { modifier_player: modifier_player, modifier_monster: modifier_monster } unless monstercard

    monsterone_card = current_player.monsterone.cards.reload.where('type=?', 'Monstercard').limit(1)
    monstertwo_card = current_player.monstertwo.cards.reload.where('type=?', 'Monstercard').limit(1)
    monsterthree_card = current_player.monsterthree.cards.reload.where('type=?', 'Monstercard').limit(1)

    # use the union gem for rails, union_all keeps duplicates that we need for player calculation
    player_monstercards = monsterone_card.union_all(monstertwo_card).union_all(monsterthree_card)

    # only add if there is a player monster that matches our good_against
    modifier_monster += monstercard.good_against_value if monstercard.good_against && player_monstercards.find_by('element=?', monstercard.read_attribute_before_type_cast('good_against'))

    # only add if there is a player monster that matches our bad_against
    modifier_monster += monstercard.bad_against_value if monstercard.bad_against && player_monstercards.find_by('element=?', monstercard.read_attribute_before_type_cast('bad_against'))

    # calc player moonster good_against values
    player_monster_good_against_value = player_monstercards.where('good_against=?', monstercard.read_attribute_before_type_cast('element')).sum(:good_against_value)

    # calc player moonster bad_against values
    player_monster_bad_against_value = player_monstercards.where('bad_against=?', monstercard.read_attribute_before_type_cast('element')).sum(:bad_against_value)

    modifier_player += player_monster_good_against_value
    modifier_player -= player_monster_bad_against_value

    { modifier_player: modifier_player, modifier_monster: modifier_monster }
  end
end

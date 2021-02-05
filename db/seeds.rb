# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

u1 = User.create!(email: 'daniela-dottolo@gmx.at', password: 'hahasosecret123', name: 'lol', password_confirmation: 'hahasosecret123')
u2 = User.create!(email: 'hallo@hallo.at', password: '235', name: 'lul', password_confirmation: '235')
u3 = User.create!(email: 'fjeorfje@gmx.at', password: 'dfergt', name: 'lel', password_confirmation: 'dfergt')
u4 = User.create!(email: 'ferjfrekpo@gmx.at', password: 'z6gtfr4', name: 'lawl', password_confirmation: 'z6gtfr4')
u5 = User.create!(email: '2@2.at', password: '2', name: '2', password_confirmation: '2')
u6 = User.create!(email: '3@3.at', password: '3', name: '3', password_confirmation: '3')
u7 = User.create!(email: '4@4.at', password: '4', name: '4', password_confirmation: '4')
u8 = User.create!(email: '5@5.at', password: '5', name: '5', password_confirmation: '5')
u9 = User.create!(email: '1@1.at', password: '1', name: '1', password_confirmation: '1')

gameboard_test = Gameboard.create!(current_state: 'lobby', player_atk: 5)

player5 = Player.create!(name: 'Gustav', gameboard: gameboard_test, user: u3)
player6 = Player.create!(name: 'Thomas', gameboard: gameboard_test, user: u2)
player7 = Player.create!(name: 'Lorenz', gameboard: gameboard_test, user: u4)

bear = Monstercard.create!(
  title: 'Sir Bear',
  description: '<p>A very serious bear with a beard.</p>',
  image: '/monster/bear.png',
  action: 'lose_item_head',
  draw_chance: 10,
  level: 3,
  element: 'earth',
  bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your headpiece.</p>',
  rewards_treasure: 1,
  good_against: 'fire',
  bad_against: 'air',
  good_against_value: 3,
  bad_against_value: 1,
  atk_points: 6,
  level_amount: 1
)

startmonster1 = Monstercard.create!(
  title: 'M 1',
  description: '<p>starting</p>',
  image: '/monster/bear.png',
  action: 'lose_item_head',
  draw_chance: 33,
  level: 1,
  element: 'fire',
  bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your headpiece.</p>',
  rewards_treasure: 1,
  good_against: 'air',
  bad_against: 'water',
  good_against_value: 3,
  bad_against_value: 1,
  atk_points: 6,
  level_amount: 1
)
startmonster2 = Monstercard.create!(
  title: 'M 2',
  description: '<p>starting</p>',
  image: '/monster/bear.png',
  action: 'lose_item_head',
  draw_chance: 33,
  level: 1,
  element: 'earth',
  bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your headpiece.</p>',
  rewards_treasure: 1,
  good_against: 'water',
  bad_against: 'air',
  good_against_value: 3,
  bad_against_value: 1,
  atk_points: 6,
  level_amount: 1
)
startmonster3 = Monstercard.create!(
  title: 'M 3',
  description: '<p>starting</p>',
  image: '/monster/bear.png',
  action: 'lose_item_head',
  draw_chance: 33,
  level: 1,
  element: 'water',
  bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your headpiece.</p>',
  rewards_treasure: 1,
  good_against: 'fire',
  bad_against: 'earth',
  good_against_value: 3,
  bad_against_value: 1,
  atk_points: 6,
  level_amount: 1
)

startmonster4 = Monstercard.create!(
  title: 'M 4',
  description: '<p>starting</p>',
  image: '/monster/bear.png',
  action: 'lose_item_head',
  draw_chance: 33,
  level: 1,
  element: 'air',
  bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your headpiece.</p>',
  rewards_treasure: 1,
  good_against: 'earth',
  bad_against: 'fire',
  good_against_value: 3,
  bad_against_value: 1,
  atk_points: 6,
  level_amount: 1
)

catfish = Monstercard.create!(
  title: 'Catfish',
  description: '<p>HA! You got catfished.</p>',
  image: '/monster/catfish.png',
  action: 'lose_level',
  draw_chance: 5,
  level: 10,
  element: 'water',
  bad_things: '<p><b>Bad things:</b>Getting catfished, really? You should know better. Lose one level.</p>',
  rewards_treasure: 2,
  good_against: 'fire',
  bad_against: 'earth',
  good_against_value: 3,
  bad_against_value: 1,
  atk_points: 14,
  level_amount: 2
)

curse = Cursecard.create!(
  title: 'very bad curse',
  description: '<p>This curse is very bad.</p><p> Actually, it is so bad that this curse will stick to you and weaken your fighting ability as long as you do not find a way to remove it</p>',
  image: '/',

  action: 'lose_atk_points',
  draw_chance: 4,
  atk_points: -1
)

item1 = Itemcard.create!(
  title: 'Helmet of Doom',
  description: '<p>This is the helmet of doom</p>',
  image: '/item/helmet.png',
  action: 'plus_one',
  draw_chance: 13,
  element: 'fire',
  element_modifier: 2,
  atk_points: 2,
  item_category: 'head',
  has_combination: false
)

item2 = Itemcard.create!(
  title: 'The things to get things out of the toilet',
  description: '<p>Disgusting. If I was you, I would not touch it.</p>',
  image: '/item/poempel.png',
  action: 'plus_one',
  draw_chance: 14,
  element: 'fire',
  element_modifier: 2,
  atk_points: 2,
  item_category: 'hand_one',
  has_combination: false
)
item3 = Itemcard.create!(
  title: 'Hermes shoes',
  description: '<p>Damn, those are some nice shoes! Hopefully hermes does not mind you took them..</p>',
  image: '/item/shoes.png',
  action: 'plus_3',
  draw_chance: 5,
  element: 'earth',
  element_modifier: 3,
  atk_points: 4,
  item_category: 'shoes',
  has_combination: false
)

# Adds cards to inventory of user1
# User.find(1).cards << (Card.find(1))
# User.find(1).cards << (Card.find(2))
# User.find(1).cards << (Card.find(3))
# User.find(1).cards << (Card.find(4))

#add cards to userinventories
u1.cards << (Card.find(4))
u2.cards << (Card.find(4))
u3.cards << (Card.find(4))
u4.cards << (Card.find(4))
u5.cards << (Card.find(4))
u6.cards << (Card.find(4))
u7.cards << (Card.find(4))
u8.cards << (Card.find(4))
u9.cards << (Card.find(4))
u1.cards << (Card.find(1))
u2.cards << (Card.find(1))
u3.cards << (Card.find(1))
u4.cards << (Card.find(1))
u5.cards << (Card.find(1))
u6.cards << (Card.find(1))
u7.cards << (Card.find(1))
u8.cards << (Card.find(1))
u9.cards << (Card.find(1))
u1.cards << (Card.find(2))
u2.cards << (Card.find(2))
u3.cards << (Card.find(2))
u4.cards << (Card.find(2))
u5.cards << (Card.find(2))
u6.cards << (Card.find(2))
u7.cards << (Card.find(2))
u8.cards << (Card.find(2))
u9.cards << (Card.find(2))
u1.cards << (Card.find(3))
u2.cards << (Card.find(3))
u3.cards << (Card.find(3))
u4.cards << (Card.find(3))
u5.cards << (Card.find(3))
u6.cards << (Card.find(3))
u7.cards << (Card.find(3))
u8.cards << (Card.find(3))
u9.cards << (Card.find(3))



levelcard = Levelcard.create!(title: 'Level up!', draw_chance: 1, description: 'Get one level', image: '/', action: 'level_up')

buffcard = Buffcard.create!(
  draw_chance: 1,
  title: 'Buffing yourself up, eh?',
  description: '<p>You are getting stronger and stronger. Gain 2 extra attack points</p>',
  image: '/',
  action: 'gain_atk',
  atk_points: 2
)

# gameboard = Gameboard.create!(current_state: 'fight', player_atk: 5)

# player1 = Player.create!(name: 'Gustav', gameboard: gameboard, user: u1)
# player2 = Player.create!(name: 'Thomas', gameboard: gameboard, user: u2)
# player3 = Player.create!(name: 'Lorenz', gameboard: gameboard, user: u3)
# player4 = Player.create!(name: 'Maja', gameboard: gameboard, user: u4)

# player1handcard = Handcard.create!(player: player1)
# p1h1 = Ingamedeck.create!(gameboard: gameboard, card: bear, cardable: player1handcard)
# p1h2 = Ingamedeck.create!(gameboard: gameboard, card: catfish, cardable: player1handcard)
# p1h3 = Ingamedeck.create!(gameboard: gameboard, card: item2,  cardable: player1handcard)
# p1h4 = Ingamedeck.create!(gameboard: gameboard, card: curse,  cardable: player1handcard)

# player1inventory = Inventory.create!(player: player1)
# p1i1 = Ingamedeck.create!(gameboard: gameboard, card: item3, cardable: player1inventory)
# player1curse = Playercurse.create!(player: player1)
# p1c1 = Ingamedeck.create!(gameboard: gameboard, card: curse, cardable: player1curse)

# player1monsterone = Monsterone.create!(player: player1)
# p1m1 = Ingamedeck.create!(gameboard: gameboard, card: bear, cardable: player1monsterone)
# p1m2 = Ingamedeck.create!(gameboard: gameboard, card: item1, cardable: player1monsterone)
# p1m3 = Ingamedeck.create!(gameboard: gameboard, card: item2, cardable: player1monsterone)
# p1m4 = Ingamedeck.create!(gameboard: gameboard, card: item3, cardable: player1monsterone)
# p1m5 = Ingamedeck.create!(gameboard: gameboard, card: bear, cardable: player1monsterone)

# Playerdeckmonstertwo.create!(id: 12, player_id: 1)
# Playerdeckmonsterthree.create!(id: 13, player_id: 1)
# Playerdeckcursecard.create!(id: 15, player_id: 2)
# Playerdeckmonsterone.create!(id: 16, player_id: 2)
# Playerdeckmonstertwo.create!(id: 17, player_id: 2)
# Playerdeckmonsterthree.create!(id: 18, player_id: 2)

# Inventory.create!(id: 1, ingamedeck_id: 2, player_id: 1)
# Inventory.create!(id: 2, ingamedeck_id: 2, player_id: 2)

# Handcard.create!(id: 3, ingamedeck_id: 2, player_id: 1)
# Ingamedeck.create!(id:3, playerdeck_id:1, gameboard_id:1, card_id:2)
# Ingamedeck.create!(id:3, playerdeck_id:1, gameboard_id:1, card_id:1)
# Ingamedeck.create!(id:1, playerdeck_id:2, gameboard_id:1, card_id:1)
# Ingamedeck.create!(id:4, playerdeck_id:2, gameboard_id:1, card_id:2)
# Ingamedeck.create!(id:5, playerdeck_id:2, gameboard_id:1, card_id:1)

# Playerdeckcursecard.create!(id: 10, player_id: 1)
# Playerdeckmonsterone.create!(id: 11, player_id: 1)

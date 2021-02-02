# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

User.create(email: 'daniela-dottolo@gmx.at', password: 'hahasosecret123', name: 'lol', password_confirmation: 'hahasosecret123')

Monstercard.create(id: 1,
                   title: 'Sir Bear',
                   description: 'A very serious bear with a beard.',
                   image: '/monster/bear.png',
                   action: 'lose_item_head',
                   draw_chance: 10,
                   level: 3,
                   element: 'earth',
                   bad_things: 'Oh no, you disrespected the Sir! Lose your headpiece.',
                   rewards_treasure: 1,
                   good_against: 'fire',
                   bad_against: 'air',
                   good_against_value: 3,
                   bad_against_value: 1,
                   atk_points: 6,
                   level_amount: 1)

Monstercard.create(id: 3,
                   title: 'Catfish',
                   description: 'HA! You got catfished.',
                   image: '/monster/catfish.png',
                   action: 'lose_level',
                   draw_chance: 5,
                   level: 10,
                   element: 'water',
                   bad_things: 'Getting catfished, really? You should know better. Lose one level.',
                   rewards_treasure: 2,
                   good_against: 'fire',
                   bad_against: 'earth',
                   good_against_value: 3,
                   bad_against_value: 1,
                   atk_points: 14,
                   level_amount: 2)

Cursecard.create(id: 2,
                 title: 'very bad curse',
                 description: 'This curse is very bad. Actually, it is so bad that this curse will stick to you and weaken your fighting ability as long as you do not find a way to remove it',
                 image: '/',
                 action: 'lose_atk_points',
                 draw_chance: 4,
                 atk_points: -1)

Itemcard.create(id: 4,
                title: 'Helmet of Doom',
                description: 'This is the helmet of doom',
                image: '/item/helmet.png',
                action: 'plus_one',
                draw_chance: 13,
                element: 'fire',
                element_modifier: 2,
                atk_points: 2,
                item_category: 'head',
                has_combination: false)

Itemcard.create(id: 5,
                title: 'The things to get things out of the toilet',
                description: 'Disgusting. If I was you, I would not touch it.',
                image: '/item/poempel.png',
                action: 'plus_one',
                draw_chance: 14,
                atk_points: 2,
                item_category: 'hand_one',
                has_combination: false)
Itemcard.create(id: 6,
                title: 'Hermes shoes',
                description: 'Damn, those are some nice shoes! Hopefully hermes does not mind you took them..',
                image: '/item/shoes.png',
                action: 'plus_3',
                draw_chance: 5,
                element: 'earth',
                element_modifier: 3,
                atk_points: 4,
                item_category: 'shoes',
                has_combination: false)

# Adds cards to inventory of user1
User.find(1).cards << (Card.find(1))
User.find(1).cards << (Card.find(2))
User.find(1).cards << (Card.find(3))
User.find(1).cards << (Card.find(4))

Levelcard.create(id: 8, title: 'Level up!', description: 'Get one level', image: '', action: 'level_up')

Buffcard.create(id: 9,
                title: 'Buffing yourself up, eh?',
                description: 'You are getting stronger and stronger. Gain 2 extra attack points',
                image: '',
                action: 'gain_atk',
                atk_points: 2)

Gameboard.create(id: 1, current_state: 'fight', player_atk: 5)

Player.create(id: 1, name: 'Gustav', gameboard_id: 1)
Player.create(id: 2, name: 'Thomas', gameboard_id: 1)
Player.create(id: 3, name: 'Lorenz', gameboard_id: 1)
Player.create(id: 4, name: 'Maja', gameboard_id: 1)

Handcard.create(id: 1, player_id: 1)
Ingamedeck.create(id: 1,  gameboard_id: 1, card_id: 1, cardable_id: 1, cardable_type: 'Handcard')
Ingamedeck.create(id: 2,  gameboard_id: 1, card_id: 3, cardable_id: 1, cardable_type: 'Handcard')
Ingamedeck.create(id: 3,  gameboard_id: 1, card_id: 5, cardable_id: 1, cardable_type: 'Handcard')
Ingamedeck.create(id: 4,  gameboard_id: 1, card_id: 2, cardable_id: 1, cardable_type: 'Handcard')

Inventory.create(id: 1, player_id: 1)
Ingamedeck.create(id: 5, gameboard_id: 1, card_id: 6, cardable_id: 1, cardable_type: 'Inventory')

Playercurse.create(id: 1, player_id: 1)
Ingamedeck.create(id: 6, gameboard_id: 1, card_id: 2, cardable_id: 1, cardable_type: 'Playercurse')

# Playerdeckmonstertwo.create(id: 12, player_id: 1)
# Playerdeckmonsterthree.create(id: 13, player_id: 1)
# Playerdeckcursecard.create(id: 15, player_id: 2)
# Playerdeckmonsterone.create(id: 16, player_id: 2)
# Playerdeckmonstertwo.create(id: 17, player_id: 2)
# Playerdeckmonsterthree.create(id: 18, player_id: 2)

# Inventory.create(id: 1, ingamedeck_id: 2, player_id: 1)
# Inventory.create(id: 2, ingamedeck_id: 2, player_id: 2)

# Handcard.create(id: 3, ingamedeck_id: 2, player_id: 1)
# Ingamedeck.create(id:3, playerdeck_id:1, gameboard_id:1, card_id:2)
# Ingamedeck.create(id:3, playerdeck_id:1, gameboard_id:1, card_id:1)
# Ingamedeck.create(id:1, playerdeck_id:2, gameboard_id:1, card_id:1)
# Ingamedeck.create(id:4, playerdeck_id:2, gameboard_id:1, card_id:2)
# Ingamedeck.create(id:5, playerdeck_id:2, gameboard_id:1, card_id:1)

# Playerdeckcursecard.create(id: 10, player_id: 1)
# Playerdeckmonsterone.create(id: 11, player_id: 1)

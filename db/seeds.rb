# frozen_string_literal: true
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)



Monstercard.create(id: 1, title: 'U Bahn', description: 'nimmt die U Bahn +3 auf deinen Roll', image: 'testurl', action: 'throwawayoneitem')
Cursecard.create(id: 2, title: 'lil vayne', description: 'do not feed', image: 'testurl', action: 'throwawayoneitem')
# Monstercard.create(id: 3, title: '', description: '1 Test Karte', image: 'testurl', action: 'throwawayoneitem')
# Monstercard.create(id: 4, title: 'Test', description: '1 Test Karte', image: 'testurl', action: 'throwawayoneitem')
# Monstercard.create(id: 5, title: 'Test', description: '1 Test Karte', image: 'testurl', action: 'throwawayoneitem')
# Bosscard.create(id: 6, title: 'Test', description: '1 Test Karte', image: 'testurl', action: 'throwawayoneitem')
# Monstercard.create(id: 7, title: 'Test', description: '1 Test Karte', image: 'testurl', action: 'throwawayoneitem')
# Levelcard.create(id: 8, title: 'Test', description: '1 Test Karte', image: 'testurl', action: 'throwawayoneitem')
# Buffcard.create(id: 9, title: 'Test', description: '1 Test Karte', image: 'testurl', action: 'throwawayoneitem')

Gameboard.create(id: 1, current_state: 'fight', player_atk: 5)

Player.create(id: 1, name: 'Gustav', gameboard_id: 1)
Handcard.create(id: 1, player_id: 1)
Ingamedeck.create(id:1,  gameboard_id:1, card_id:1, cardable_id:1, cardable_type: 'Handcard')
Ingamedeck.create(id:2,  gameboard_id:1, card_id:2,  cardable_id:1, cardable_type: 'Handcard')


# Player.create(id: 2, name: 'Thomas', gameboard_id: 1)


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

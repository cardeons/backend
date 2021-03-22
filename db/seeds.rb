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

# player5 = Player.create!(name: 'Gustav', gameboard: gameboard_test, user: u3)
# player6 = Player.create!(name: 'Thomas', gameboard: gameboard_test, user: u2)
# player7 = Player.create!(name: 'Lorenz', gameboard: gameboard_test, user: u4)


## Monstercards

##bear
bear_fire = Monstercard.create!(
  title: 'Sir Bear',
  description: '<p><b>*slaps you with his glove*</b> I challenge you to a duel!</p>',
  image: '/monster/Baer_Orange.png',
  action: 'lose_item_hand',
  draw_chance: 10,
  level: 5,
  element: 'fire',
  bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose one hand thing.</p>',
  rewards_treasure: 1,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 0,
  atk_points: 5,
  level_amount: 1
)

bear_water = Monstercard.create!(
  title: 'Sir Bear',
  description: '<p><b>*slaps you with his glove*</b> I challenge you to a duel! -3 Against Hot Dog and Buffalo Wings. He is not willing to touch those.</p>',
  image: '/monster/Baer_Dunkelblau.png',
  action: 'lose_item_shoe',
  draw_chance: 10,
  level: 10,
  element: 'water',
  bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your shoes.</p>',
  rewards_treasure: 3,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 3,
  atk_points: 10,
  level_amount: 1
)

bear_earth = Monstercard.create!(
  title: 'Sir Bear',
  description: '<p><b>*slaps you with his glove*</b> I challenge you to a duel! +2 against Water</p>',
  image: '/monster/Baer_Gruen.png',
  action: 'lose_item_shoe',
  draw_chance: 10,
  level: 7,
  element: 'earth',
  bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose one hand thing.</p>',
  rewards_treasure: 1,
  good_against: 'water',
  bad_against: '',
  good_against_value: 2,
  bad_against_value: 0,
  atk_points: 7,
  level_amount: 1
)

bear_air = Monstercard.create!(
  title: 'Sir Bear',
  description: '<p><b>*slaps you with his glove*</b> I challenge you to a duel!</p>',
  image: '/monster/Baer_Hellblau.png',
  action: 'lose_item_shoe',
  draw_chance: 10,
  level: 15,
  element: 'air',
  bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your shoes.</p>',
  rewards_treasure: 3,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 0,
  atk_points: 15,
  level_amount: 1
)

# startmonster1 = Monstercard.create!(
#   title: 'M 1',
#   description: '<p>starting</p>',
#   image: '/monster/bear.png',
#   action: 'lose_item_head',
#   draw_chance: 33,
#   level: 1,
#   element: 'fire',
#   bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your headpiece.</p>',
#   rewards_treasure: 1,
#   good_against: 'air',
#   bad_against: 'water',
#   good_against_value: 3,
#   bad_against_value: 1,
#   atk_points: 6,
#   level_amount: 1
# )
# startmonster2 = Monstercard.create!(
#   title: 'M 2',
#   description: '<p>starting</p>',
#   image: '/monster/bear.png',
#   action: 'lose_item_head',
#   draw_chance: 33,
#   level: 1,
#   element: 'earth',
#   bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your headpiece.</p>',
#   rewards_treasure: 1,
#   good_against: 'water',
#   bad_against: 'air',
#   good_against_value: 3,
#   bad_against_value: 1,
#   atk_points: 6,
#   level_amount: 1
# )
# startmonster3 = Monstercard.create!(
#   title: 'M 3',
#   description: '<p>starting</p>',
#   image: '/monster/bear.png',
#   action: 'lose_item_head',
#   draw_chance: 33,
#   level: 1,
#   element: 'water',
#   bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your headpiece.</p>',
#   rewards_treasure: 1,
#   good_against: 'fire',
#   bad_against: 'earth',
#   good_against_value: 3,
#   bad_against_value: 1,
#   atk_points: 6,
#   level_amount: 1
# )

# startmonster4 = Monstercard.create!(
#   title: 'M 4',
#   description: '<p>starting</p>',
#   image: '/monster/bear.png',
#   action: 'lose_item_head',
#   draw_chance: 33,
#   level: 1,
#   element: 'air',
#   bad_things: '<p><b>Bad things:</b>Oh no, you disrespected the Sir!</p><p> Lose your headpiece.</p>',
#   rewards_treasure: 1,
#   good_against: 'earth',
#   bad_against: 'fire',
#   good_against_value: 3,
#   bad_against_value: 1,
#   atk_points: 6,
#   level_amount: 1
# )

##catfish
catfish_fire = Monstercard.create!(
  title: 'Catfish',
  description: '<p>Is it a cat? Is it a fish? I don’t know! -3 Against Hot Dog</p>',
  image: '/monster/CatFish_Orange.png',
  action: 'random_card_lowest_level',
  draw_chance: 5,
  level: 7,
  element: 'fire',
  bad_things: '<p><b>Bad things:</b>Got catfished, really? You should know better.. Give a random card to the player with the lowest level. </p>',
  rewards_treasure: 1,
  good_against: 'fire',
  bad_against: 'earth',
  good_against_value: 0,
  bad_against_value: 3,
  atk_points: 7,
  level_amount: 1
)

catfish_earth = Monstercard.create!(
  title: 'Catfish',
  description: '<p>Is it a cat? Is it a fish? I don’t know! -3 Against Hot Dog</p>',
  image: '/monster/CatFish_Gruen.png',
  action: 'lose_one_card',
  draw_chance: 5,
  level: 10,
  element: 'earth',
  bad_things: '<p><b>Bad things:</b>Got catfished, really? You should know better.. Lose one card. </p>',
  rewards_treasure: 2,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 3,
  atk_points: 10,
  level_amount: 1
)

catfish_water = Monstercard.create!(
  title: 'Catfish',
  description: '<p>I don’t think cats like water so it’s probably a fish? +3 Against Fire Hot Dog</p>',
  image: '/monster/CatFish_Dunkelblau.png',
  action: 'random_card_lowest_level',
  draw_chance: 5,
  level: 4,
  element: 'water',
  bad_things: '<p><b>Bad things:</b>Got catfished, really? You should know better.. Give a random card to the player with the lowest level. </p>',
  rewards_treasure: 1,
  good_against: '',
  bad_against: '',
  good_against_value: 3,
  bad_against_value: 0,
  atk_points: 4,
  level_amount: 1
)

catfish_air = Monstercard.create!(
  title: 'Catfish',
  description: '<p>Is it a cat? Is it a fish? Love is not in the air! -3 Against Hot Dog</p>',
  image: '/monster/CatFish_Hellblau.png',
  action: 'lose_level',
  draw_chance: 5,
  level: 18,
  element: 'air',
  bad_things: '<p><b>Bad things:</b>Got catfished, really? You should know better.. Give a random card to the player with the lowest level. </p>',
  rewards_treasure: 3,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 3,
  atk_points: 18,
  level_amount: 1
)


##Pit-Bull
pitbull_water = Monstercard.create!(
  title: 'Pit-Bull',
  description: '<p>Only listens to Mister Worldwide. +3 against Fire Monster!</p>',
  image: '/monster/PitBull_Dunkelblau.png',
  action: 'lose_item_head',
  draw_chance: 5,
  level: 5,
  element: 'water',
  bad_things: '<p><b>Bad things:</b>Picture that with a Kodak: Lose some cool sunglasses or your headpiece!</p>',
  rewards_treasure: 1,
  good_against: 'fire',
  bad_against: '',
  good_against_value: 3,
  bad_against_value: 0,
  atk_points: 5,
  level_amount: 1
)

pitbull_earth = Monstercard.create!(
  title: 'Pit-Bull',
  description: '<p>Only listens to Mister Worldwide. +1 against Water Monster!</p>',
  image: '/monster/PitBull_Gruen.png',
  action: 'lose_item_head',
  draw_chance: 5,
  level: 3,
  element: 'earth',
  bad_things: '<p><b>Bad things:</b>Picture that with a Kodak: Lose some cool sunglasses or your headpiece!</p>',
  rewards_treasure: 1,
  good_against: 'water',
  bad_against: '',
  good_against_value: 1,
  bad_against_value: 0,
  atk_points: 3,
  level_amount: 1
)

pitbull_fire = Monstercard.create!(
  title: 'Pit-Bull',
  description: '<p>Only listens to Mister Worldwide. +5 against Air Monster!</p>',
  image: '/monster/PitBull_Orange.png',
  action: 'lose_item_head',
  draw_chance: 5,
  level: 8,
  element: 'fire',
  bad_things: '<p><b>Bad things:</b>Picture that with a Kodak: Lose some cool sunglasses or your headpiece!</p>',
  rewards_treasure: 2,
  good_against: 'air',
  bad_against: '',
  good_against_value: 5,
  bad_against_value: 0,
  atk_points: 8,
  level_amount: 1
)

pitbull_air = Monstercard.create!(
  title: 'Pit-Bull',
  description: '<p>Only listens to Mister Worldwide. +7 against Earth Monster!</p>',
  image: '/monster/PitBull_Hellblau.png',
  action: 'lose_item_head',
  draw_chance: 5,
  level: 12,
  element: 'air',
  bad_things: '<p><b>Bad things:</b>Picture that with a Kodak: Lose some cool sunglasses or your headpiece!</p>',
  rewards_treasure: 3,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 3,
  atk_points: 12,
  level_amount: 1
)


##Buffalo Wings
buffalowings_water = Monstercard.create!(
  title: 'Buffalo Wings',
  description: '<p>Buffalo wings are an all time favorite, they’re perfect for parties!</p>',
  image: '/monster/BuffaloWings_Dunkelblau.png',
  action: 'lose_level',
  draw_chance: 5,
  level: 3,
  element: 'water',
  bad_things: '<p><b>Bad things:</b>Too hot to handle! Lose a Level!</p>',
  rewards_treasure: 1,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 0,
  atk_points: 3,
  level_amount: 1
)

buffalowings_earth = Monstercard.create!(
  title: 'Buffalo Wings',
  description: '<p>Buffalo wings are an all time favorite, they’re perfect for parties! +3 Against Fire Monster!</p>',
  image: '/monster/BuffaloWings_Gruen.png',
  action: 'lose_level',
  draw_chance: 5,
  level: 9,
  element: 'earth',
  bad_things: '<p><b>Bad things:</b>Too hot to handle! Lose a Level!</p>',
  rewards_treasure: 2,
  good_against: 'fire',
  bad_against: '',
  good_against_value: 3,
  bad_against_value: 0,
  atk_points: 9,
  level_amount: 1
)

buffalowings_air = Monstercard.create!(
  title: 'Buffalo Wings',
  description: '<p>Buffalo wings are an all time favorite, they’re perfect for parties! -2 Against Fire Monster!</p>',
  image: '/monster/BuffaloWings_Hellblau.png',
  action: 'lose_level',
  draw_chance: 5,
  level: 5,
  element: 'air',
  bad_things: '<p><b>Bad things:</b>Too hot to handle! Lose a Level!</p>',
  rewards_treasure: 1,
  good_against: '',
  bad_against: 'fire',
  good_against_value: 0,
  bad_against_value: 2,
  atk_points: 5,
  level_amount: 1
)

buffalowings_fire = Monstercard.create!(
  title: 'Buffalo Wings',
  description: '<p>Buffalo wings are an all time favorite, they’re perfect for parties! +7 Against Water Monster, -3 Against Earth Monster! Won’t follow a Player under Level 3.</p>',
  image: '/monster/BuffaloWings_Orange.png',
  action: 'die',
  draw_chance: 5,
  level: 16,
  element: 'fire',
  bad_things: '<p><b>Bad things:</b>Too hot to handle! You die, lose all your Levels!</p>',
  rewards_treasure: 3,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 0,
  atk_points: 16,
  level_amount: 1
)


##Unicorn
unicorn_water = Monstercard.create!(
  title: 'Unicorn',
  description: '<p>It is the perfect movie partner! It brings its own wet popcorn! +3 Against Buffalo Wings and Hotdogs. It will be the only snack at the party!</p>',
  image: '/monster/UniCorn_Dunkelblau.png',
  action: 'lose_level',
  draw_chance: 5,
  level: 10,
  element: 'water',
  bad_things: '<p><b>Bad things:</b>Oh no, it seems like the popcorn is soaking wet! You eat it out of respect and lose one level because it is so disgusting.</p>',
  rewards_treasure: 3,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 0,
  atk_points: 10,
  level_amount: 1
)

unicorn_earth = Monstercard.create!(
  title: 'Unicorn',
  description: '<p>It is just a horse with corn stuck on its head. What did you expect?</p>',
  image: '/monster/UniCorn_Gruen.png',
  action: 'lose_item_hand',
  draw_chance: 5,
  level: 7,
  element: 'earth',
  bad_things: '<p><b>Bad things:</b>The Corn is not done and still on the fields… You lose one hand thing!</p>',
  rewards_treasure: 2,
  good_against: 'fire',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 0,
  atk_points: 7,
  level_amount: 1
)

unicorn_air = Monstercard.create!(
  title: 'Unicorn',
  description: '<p>Ever tried Popcorn out of an Airfryer? Me neither. +3 Against Air Monster</p>',
  image: '/monster/UniCorn_Hellblau.png',
  action: 'lose_level',
  draw_chance: 5,
  level: 15,
  element: 'air',
  bad_things: '<p><b>Bad things:</b>The Corn flies away and so does your future. Lose one level.</p>',
  rewards_treasure: 3,
  good_against: 'air',
  bad_against: '',
  good_against_value: 3,
  bad_against_value: 0,
  atk_points: 15,
  level_amount: 1
)

unicorn_fire = Monstercard.create!(
  title: 'Unicorn',
  description: '<p>The corn is ready to pop! Wanna try some? +3 Against Water Monster</p>',
  image: '/monster/UniCorn_Orange.png',
  action: 'no_help_next_fight',
  draw_chance: 5,
  level: 5,
  element: 'fire',
  bad_things: '<p><b>Bad things:</b>You got some Popcorn stuck between your teeth! Gross! You can’t get it out. No one is willing to help you in your next fight!</p>',
  rewards_treasure: 1,
  good_against: 'water',
  bad_against: '',
  good_against_value: 3,
  bad_against_value: 0,
  atk_points: 5,
  level_amount: 1
)


##HotDog
hotdog_water = Monstercard.create!(
  title: 'Wet Hot Dog',
  description: '<p>Your Hot Dog fell into a lake! +5 Against Fire Monster</p>',
  image: '/monster/HotDog_Dunkelblau.png',
  action: 'lose_level',
  draw_chance: 5,
  level: 15,
  element: 'water',
  bad_things: '<p><b>Bad things:</b>Wet dogs smell horrible. You run away and lose a level!</p>',
  rewards_treasure: 3,
  good_against: 'fire',
  bad_against: '',
  good_against_value: 5,
  bad_against_value: 0,
  atk_points: 15,
  level_amount: 1
)

hotdog_earth = Monstercard.create!(
  title: 'Dirty Hot Dog',
  description: '<p>Dirty Talk? No, I said dirty dog! -3 Against Boaring, he just doesn’t care if it’s dirty.</p>',
  image: '/monster/HotDog_Gruen.png',
  action: 'lose_item_hand',
  draw_chance: 5,
  level: 9,
  element: 'earth',
  bad_things: '<p><b>Bad things:</b>Your Hot Dog fell on the ground. You still try to eat it and poison yourself. Lose one hand thing.</p>',
  rewards_treasure: 2,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 3,
  atk_points: 9,
  level_amount: 1
)

hotdog_air = Monstercard.create!(
  title: 'Flying Hot Dog',
  description: '<p>Is it a bird? Is it a plane? No it’s a Hot Dog! Is it falling or flying? We don’t know yet!</p>',
  image: '/monster/HotDog_Hellblau.png',
  action: 'lose_item',
  draw_chance: 5,
  level: 4,
  element: 'air',
  bad_things: '<p><b>Bad things:</b>Looks more like Falling, you lose an item!</p>',
  rewards_treasure: 1,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 0,
  atk_points: 4,
  level_amount: 1
)

unicorn_fire = Monstercard.create!(
  title: 'Hawt Dog',
  description: '<p>Would you like some chili sauce for your hotdog? +3 Against Buffalo Wings, there can only be one.</p>',
  image: '/monster/HotDog_Orange.png',
  action: 'lose_item_hand',
  draw_chance: 5,
  level: 6,
  element: 'fire',
  bad_things: '<p><b>Bad things:</b>Oh no, it’s way too hot! You burn your tongue and lose a weapon.</p>',
  rewards_treasure: 2,
  good_against: '',
  bad_against: '',
  good_against_value: 3,
  bad_against_value: 0,
  atk_points: 6,
  level_amount: 1
)


##Boaring
boaring_water = Monstercard.create!(
  title: 'Boaring',
  description: '<p>He is wet. Still bored.</p>',
  image: '/monster/Willdschwein_Dunkelblau.png',
  action: 'lose_level',
  draw_chance: 5,
  level: 13,
  element: 'water',
  bad_things: '<p><b>Bad things:</b>He almost bored you to death. Lose a level!</p>',
  rewards_treasure: 3,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 0,
  atk_points: 13,
  level_amount: 1
)

boaring_earth = Monstercard.create!(
  title: 'Boaring',
  description: '<p>He is dirty. Still bored. +4 Against Water Monster!</p>',
  image: '/monster/Willdschwein_Gruen.png',
  action: 'lose_item_hand',
  draw_chance: 5,
  level: 11,
  element: 'earth',
  bad_things: '<p><b>Bad things:</b>He almost bored you to death. Lose a weapon!</p>',
  rewards_treasure: 2,
  good_against: 'water',
  bad_against: '',
  good_against_value: 4,
  bad_against_value: 0,
  atk_points: 11,
  level_amount: 1
)

boaring_air = Monstercard.create!(
  title: 'Boaring',
  description: '<p>He is flying. Still bored. +3 for every fire monster he fights.</p>',
  image: '/monster/Willdschwein_Hellblau.png',
  action: 'die',
  draw_chance: 5,
  level: 18,
  element: 'air',
  bad_things: '<p><b>Bad things:</b>He bored you to death. Lose all levels.</p>',
  rewards_treasure: 4,
  good_against: 'fire',
  bad_against: '',
  good_against_value: 3,
  bad_against_value: 0,
  atk_points: 18,
  level_amount: 1
)

boaring_fire = Monstercard.create!(
  title: 'Boaring',
  description: '<p>He is on fire. Still bored.</p>',
  image: '/monster/Willdschwein_Orange.png',
  action: 'no_action',
  draw_chance: 5,
  level: 6,
  element: 'fire',
  bad_things: '<p><b>Bad things:</b>He almost bored you to death. Nothing happens, you are still bored.</p>',
  rewards_treasure: 1,
  good_against: '',
  bad_against: '',
  good_against_value: 0,
  bad_against_value: 0,
  atk_points: 6,
  level_amount: 1
)

curse = Cursecard.create!(
  title: 'very bad curse',
  description: '<p>This curse is very bad.</p><p> Actually, it is so bad that this curse will stick to you and weaken your fighting ability as long as you do not find a way to remove it</p>',
  image: '/',
  action: 'lose_atk_points',
  draw_chance: 4,
  atk_points: -1
)

# item1 = Itemcard.create!(
#   title: 'Helmet of Doom',
#   description: '<p>This is the helmet of doom</p>',
#   image: '/item/helmet.png',
#   action: 'plus_one',
#   draw_chance: 13,
#   element: 'fire',
#   element_modifier: 2,
#   atk_points: 2,
#   item_category: 'head',
#   has_combination: false
# )

# item2 = Itemcard.create!(
#   title: 'The things to get things out of the toilet',
#   description: '<p>Disgusting. If I was you, I would not touch it.</p>',
#   image: '/item/poempel.png',
#   action: 'plus_one',
#   draw_chance: 14,
#   element: 'fire',
#   element_modifier: 2,
#   atk_points: 2,
#   item_category: 'hand_one',
#   has_combination: false
# )


##mullet
mullet = Itemcard.create!(
  title: 'Mullet',
  description: '<p>Very fancy 80s hair. -3 Stylepoints</p>',
  image: '/item/Vokuhila_Hellblau.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'head',
  has_combination: false
)

##roman helmet
roman_helmet = Itemcard.create!(
  title: 'Roman Helmet',
  description: '<p>Asterix will hate you! +2 Against Boaring</p>',
  image: '/item/Helm_Orange.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 1,
  item_category: 'head',
  has_combination: false
)

##pizza
tunapizza = Itemcard.create!(
  title: 'Tuna Pizza Shield',
  description: '<p>Mamma mia, molto bene! +3 when combined with a pizza cutter!</p>',
  image: '/item/Pizza_Dunkelblau.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'water',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'hand',
  has_combination: true
)

veggiepizza = Itemcard.create!(
  title: 'Veggie Pizza Shield',
  description: '<p>Mamma mia, molto bene! +3 when combined with a pizza cutter!</p>',
  image: '/item/Pizza_Gruen.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'water',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'hand',
  has_combination: true
)

chickenpizza = Itemcard.create!(
  title: 'Chicken Pizza Shield',
  description: '<p>Mamma mia, prosciutto? no chickerino! +3 when combined with a pizza cutter!</p>',
  image: '/item/Pizza_Hellblau.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'air',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'hand',
  has_combination: true
)

diavolopizza = Itemcard.create!(
  title: 'Diavolo Pizza Shield',
  description: '<p>Mamma mia, oh mio dio, che caldo! +3 when combined with a pizza cutter!</p>',
  image: '/item/Pizza_Orange.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'fire',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'hand',
  has_combination: true
)

##pizza cutter
pizzacutter = Itemcard.create!(
  title: 'Pizza Cutter',
  description: '<p>Cuts pizza! +3 if you have a Pizza.</p>',
  image: '/item/Pizzaschneider.png',
  action: 'plus_3_if_combination',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 3,
  atk_points: 3,
  item_category: 'hand',
  has_combination: true
)

##controller
controller = Itemcard.create!(
  title: 'Controller',
  description: '<p>You better not use it for this game.</p>',
  image: '/item/Controller_Dunkelblau.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 2,
  item_category: 'hand',
  has_combination: false
)


##the one ring
the_one_ring = Itemcard.create!(
  title: 'The One Ring',
  description: '<p>One Ring to rule them all! The Ring has awoken, it’s heard its master’s call.</p>',
  image: '/item/Ring_Hellblau.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 1,
  item_category: 'none',
  has_combination: false
)


##german tourist shoes
german_tourist_shoes = Itemcard.create!(
  title: 'German Tourist Shoes',
  description: '<p>Oh no, a german tourist on the run! Hide your towels!</p>',
  image: '/item/Sandalen_Dunkelblau.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'shoe',
  has_combination: false
)

##ironing board
ironing_board = Itemcard.create!(
  title: 'Ironing Board',
  description: '<p>Can handle hot stuff. You can use it as a shield!</p>',
  image: '/item/Buegelbrett.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 2,
  item_category: 'hand',
  has_combination: false
)

##Plunger
plunger = Itemcard.create!(
  title: 'Plunger',
  description: '<p>The thing to get things out of the toilet.</p>',
  image: '/item/Puempel.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 2,
  item_category: 'hand',
  has_combination: false
)

##Ladle
ladle = Itemcard.create!(
  title: 'Ladle',
  description: '<p>You can use it to get soup OR to hit your enemies. Maybe your enemies are hungry?</p>',
  image: '/item/Schoepfkelle.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 2,
  item_category: 'hand',
  has_combination: false
)

##Rubber ring
rubber_ring = Itemcard.create!(
  title: 'Rubber Ring',
  description: '<p>You ain’t afraid of water. +3 against water monster.</p>',
  image: '/item/Schiwmmreifen_Gruen.png',
  action: 'plus_three',
  draw_chance: 5,
  element: 'water',
  element_modifier: 3,
  atk_points: 2,
  item_category: 'none',
  has_combination: false
)

##Sunglasses
sunglasses = Itemcard.create!(
  title: 'Sunglasses',
  description: '<p>+3 when worn by Pit-Bull, transforms him into Mister World Wide!</p>',
  image: '/item/Sonnenbrille_Hellblau.png',
  action: 'plus_three_if_combination',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 3,
  atk_points: 2,
  item_category: 'none',
  has_combination: true
)


##Water Gun
water_gun = Itemcard.create!(
  title: 'Water Gun',
  description: '<p>+3 against fire monster.</p>',
  image: '/item/Wasserpistole.png',
  action: 'plus_three',
  draw_chance: 5,
  element: 'water',
  element_modifier: 3,
  atk_points: 2,
  item_category: 'hand',
  has_combination: false
)

##Wand
wand = Itemcard.create!(
  title: 'Wand',
  description: '<p>You are a wizard, player!</p>',
  image: '/item/Zauberstab_Orange.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'hand',
  has_combination: false
)

##Whip
whip = Itemcard.create!(
  title: 'Whip',
  description: '<p>Use it for your horse or something else ;-). +2 against Unicorns.</p>',
  image: '/item/Gerte.png',
  action: 'plus_two',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 2,
  atk_points: 3,
  item_category: 'hand',
  has_combination: false
)

##Dagger
dagger = Itemcard.create!(
  title: 'Dagger',
  description: '<p>Sneaky thief!</p>',
  image: '/item/Dolch_Dunkelblau.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'hand',
  has_combination: false
)

##hermes
item3 = Itemcard.create!(
  title: 'Hermes shoes',
  description: '<p>Damn, WHAT ARE THOOOSE. Hopefully hermes does not mind you took them.</p>',
  image: '/item/shoes.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'shoes',
  has_combination: false
)

##spaghetto_head
spaghetto_head = Itemcard.create!(
  title: 'Spaghetti Head',
  description: '<p>You accept the flying spaghetti monster as your lord and savior!</p>',
  image: '/item/Nudelsieb.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 2,
  item_category: 'head',
  has_combination: false
)


##Berserker axe
berserker_axe = Itemcard.create!(
  title: 'Berserker Axe',
  description: '<p>Boy!</p>',
  image: '/item/Axt_Orange.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'hand',
  has_combination: false
)

##Katana
katana = Itemcard.create!(
  title: 'Katana',
  description: '<p>+3 against Weebs. Omae wa mou shinderu!</p>',
  image: '/item/Katana.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'hand',
  has_combination: false
)

##Saddle
saddle = Itemcard.create!(
  title: 'Saddle',
  description: '<p>Perfect accessory for a horse girl. BRR! +2 if equipped on a Unicorn</p>',
  image: '/item/Sattel_Hellblau.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 2,
  atk_points: 1,
  item_category: 'hand',
  has_combination: true
)


##Morning star
morning_star = Itemcard.create!(
  title: 'Morning Star',
  description: '<p>The perfect weapon of the devil.</p>',
  image: '/item/Morgenstern.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'hand',
  has_combination: false
)

##Toothbrush
toothbrush = Itemcard.create!(
  title: 'Toothbrush',
  description: '<p>Slayer of morning breath.</p>',
  image: '/item/Zahnbuerste_Gruen.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 1,
  item_category: 'hand',
  has_combination: false
)

##Spongebobs Spatula
spongebobs_spatula = Itemcard.create!(
  title: 'Spongebobs Spatula',
  description: '<p>Even the Hash-Slinging Slasher lives in fear of this weapon.</p>',
  image: '/item/Pfannenwender.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 2,
  item_category: 'hand',
  has_combination: false
)

##Crown
crown = Itemcard.create!(
  title: 'Crown',
  description: '<p>Suits a king. + 3 when Sir Bear wears it.</p>',
  image: '/item/Krone.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 3,
  atk_points: 2,
  item_category: 'hand',
  has_combination: true
)


##Bow and arrow
bow_and_arrow = Itemcard.create!(
  title: 'Bow and Arrow',
  description: '<p></p>',
  image: '/item/Pfeil_Und_Bogen_Gruen.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 3,
  item_category: 'hand',
  has_combination: false
)

##Excalibur
excalibur = Itemcard.create!(
  title: 'Excalibur',
  description: '<p></p>',
  image: '/item/Schwert_Hellblau.png',
  action: 'no_action',
  draw_chance: 5,
  element: 'no_element',
  element_modifier: 0,
  atk_points: 2,
  item_category: 'hand',
  has_combination: false
)


# Adds cards to inventory of user1
# User.find(1).cards << (Card.find(1))
# User.find(1).cards << (Card.find(2))
# User.find(1).cards << (Card.find(3))
# User.find(1).cards << (Card.find(4))

# add cards to userinventories
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

levelcard = Levelcard.create!(title: 'Level up!', draw_chance: 1, description: 'Get one level', image: '/', action: 'level_up', level_amount: 1)

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

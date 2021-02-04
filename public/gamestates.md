{
  action: ''
  
}
#lobby_channel
{
  type: 'START_GAME',
  params: {
    game_id: integer
  }
}

#playerchannel
{
  player_id:integer ,
  handcard: [
    {
      card_id: integer,
      unique_card_id: integer
    }
  ]
}

#gameboardchannel
{
  gameboard: {
    gameboard_id: integer,
    current_player: player_id,
    center_card: card_id,
    player_atk: integer,
    monster_atk: integer,
    success: bool,
    can_flee: bool,
    asked_help: bool,
    shared_reward: int,
    helping_player: nil
  },
  players: [{
    player_id: ,
    name: ,
    level: ,
    attack: ,
    handcard: integer,
    inventory: [
      {
        card_id: int,
        unique_card_id: int
      }
    ],
    playercurse: [
      {
        card_id: int,
        unique_card_id: int
      }
    ],
    monsters: [
      { 
        card_id: ,
        unique_card_id: ,
        items: [
          {
            card_id: ,
            unique_card_id: ,
          }
        ]
      }
    ]
  }]
}


#FROM FRONTEND
#ANFRAGE
{
  action: "move_card",
  to: "",
  unique_card_id: 
  #from und to soll folgendes sein: "inventory", "handcards", "monsterone", "monstertwo", "monsterthree", "center"
}

#ANTWORT
{
  gameboard: {
    gameboard_id: integer,
    current_player: player_id,
    center_card: card_id,
    player_atk: integer,
    monster_atk: integer,
    success: bool,
    can_flee: bool,
    asked_help: bool,
    shared_reward: int,
    helping_player: nil
  },
  players: [{
    player_id: ,
    name: ,
    level: ,
    attack: ,
    handcard: integer,
    inventory: [
      {
        card_id: int,
        unique_card_id: int
      }
    ],
    playercurse: [
      {
        card_id: int,
        unique_card_id: int
      }
    ],
    monsters: [
      { 
        card_id: ,
        unique_card_id: ,
        items: [
          {
            card_id: ,
            unique_card_id: ,
          }
        ]
      }
    ]
  }]
}

#ANFRAGE
{
  action: "curse_player",
  to: ,
  unique_card_id: 
  #to ist die id des anderen Spielers, der verflucht wird
}

#ANTWORT
{
  gameboard: {
    gameboard_id: integer,
    current_player: player_id,
    center_card: card_id,
    player_atk: integer,
    monster_atk: integer,
    success: bool,
    can_flee: bool,
    asked_help: bool,
    shared_reward: int,
    helping_player: nil
  },
  players: [{
    player_id: ,
    name: ,
    level: ,
    attack: ,
    handcard: integer,
    inventory: [
      {
        card_id: int,
        unique_card_id: int
      }
    ],
    playercurse: [
      {
        card_id: int,
        unique_card_id: int
      }
    ],
    monsters: [
      { 
        card_id: ,
        unique_card_id: ,
        items: [
          {
            card_id: ,
            unique_card_id: ,
          }
        ]
      }
    ]
  }]
}

#ANFRAGE
{
  action: "draw_door_card"
}

#ANTWORT
{
  gameboard: {
      gameboard_id: integer,
      current_player: player_id,
      center_card: card_id, #updatet
      player_atk: integer,
      monster_atk: integer,
      success: false,
      rewards_treasure: 0,
      can_flee: true/false,
      asked_help: false,
      shared_reward: int,
      helping_player: player_id
    }
}

#ANFRAGE
{
  action: "flee"
}
#ANTWORT
{
  gameboard: {
      gameboard_id: integer,
      current_player: player_id,
      center_card: card_id,
      player_atk: integer,
      monster_atk: integer,
      success: false,
      rewards_treasure: 0,
      can_flee: true/false,
      asked_help: false,
      shared_reward: int,
      helping_player: player_id
    }
}
{
  action: "intercept",
  unique_card_id:
  to: 
  #to - monster oder fighting player
}
#Antwort
{
  gameboard: {
      gameboard_id: integer,
      current_player: player_id,
      center_card: card_id,
      player_atk: integer, #updatet
      monster_atk: integer, #updatet
      success: bool,
      can_flee: bool,
      asked_help: true,
      shared_reward: int,
      helping_player: player_id
    },
    interceptcards: [
      {
        card_id: int,
        unique_card_id: int
      }
    ]
  }
}

#ANFRAGE
{
  action: "help",
  helping_player: ,
  is_helping: ?,
}

#ANTWORT
{
  gameboard: {
      gameboard_id: integer,
      current_player: player_id,
      center_card: card_id,
      player_atk: integer,
      monster_atk: integer,
      success: bool,
      can_flee: bool,
      asked_help: true,
      shared_reward: int,
      helping_player: player_id
    }
  }
}

#ANFRAGE
{
  action: "no_interception",
}

#ANTWORT 
{
  gameboard: {
      gameboard_id: integer,
      current_player: next_player_id,
      center_card: card_id,
      player_atk: integer,
      monster_atk: integer,
      success: true,
      rewards_treasure: 4,
      can_flee: bool,
      asked_help: false,
      shared_reward: int,
      helping_player: player_id
    }
}
#playerchannel
{
  player_id:integer ,
  handcard: [
    {
      card_id: integer,
      unique_card_id: integer
    }
  ]
}
#lobby_channel
ANTWORT
{
  type: 'START_GAME',
  params: {
    game_id: integer
  }
}

#playerchannel
ANTWORT
{
  type : "HANDCARD_UPDATE",
  params:
  {  
    handcard: [
      {
        card_id: integer,
        unique_card_id: integer
      }
    ]    
  }
}

ANTWORT
#gameboardchannel
{
  type : "BOARD_UPDATE",
  params:{
    gameboard: {
      gameboard_id: integer,
      current_player: player_id,
      center_card: card_id,
      player_atk: integer,
      monster_atk: integer,
      interceptcards: [
        {
          card_id: int,
          unique_card_id: int
        }
      ]
      player_interceptcards: [
        {
          card_id: int,
          unique_card_id: int
        }
      ]
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
          item: [
            {
              card_id: ,
              unique_card_id: ,
            }
          ]
        }
      ]
    }]
  }
}


PLAYER Channel response
{
  type: ERROR,
  params:
  {
    message: "error msg...."
  }
}


Gameboard Channel response
{
  type: "GAME_LOG",
  params:
  {
    date: ISOSTRING,
    message: "game log"
  }
}


#FROM FRONTEND
#ANFRAGE move monster or items to player
{
  action: "move_card",
  unique_card_id:  int
  to: "inventory" | "player_monster"
}

#ANTWORT
{
  #GAMEBOARD WIE IMMER
}

#ANFRAGE equip monster
{
  action: "equip_monster",
  unique_monster_id:  int
  unique_equip_id:  int
}

#ANTWORT
{
  #GAMEBOARD WIE IMMER
}


#ANFRAGE decide between play_monster or draw_door_card
{
  action: "play_monster",
  unique_card_id:  int
}

#ANTWORT
{
  #GAMEBOARD WIE IMMER
}

#ANFRAGE
{
  action: "draw_door_card"
}

#ANTWORT
{
  #GAMEBOARD WIE IMMER
}



<!-- #ANFRAGE
{
  action: "curse_player",
  to: 1,
  unique_card_id: 4
  #to ist die id des anderen Players, der verflucht wird
} -->

<!-- #ANTWORT
{
  #GAMEBOARD WIE IMMER
} -->


#ANFRAGE
{
  action: "flee"
}
#ANTWORT
{
   type: 'FLEE',
   params: 
   { 
     flee: boolean,
     value: int
    } 
}

#ANTWORT
{
  #GAMEBOARD WIE IMMER
}


#ANFRAGE 
{
  action: "intercept",
  unique_card_id: 1,
  to: 'center_card' | 'current_player'
}
#Antwort
{
  GAMEBOARD WIE OBEN
}



#ANFRAGE
{
  action: "help_call",
  helping_player_id: 1,
  helping_shared_rewards: 1,
}

#ANTWORT im PLAYER CHANNEL oder wies dir lieber is
{
   type: 'ASK_FOR_HELP',
   params: 
   { 
     player_id: 1,
     player_name: "gustav"
     helping_shared_rewards: 1,
    }  
}

#ANFRAGE
  {
  action: "answer_help_call",
  params:{
    help: boolean
    }
  }

#Antwort
  {
    GAMEBOARD WIE OBEN
  }




#ANFRAGE
#kein player möchte in den kampf eingreifen
{
  action: "no_interception",
}

#ANTWORT 
{
    GAMEBOARD WIE OBEN
}


#playerchannel draw Cards from Rewards
{
   type: 'REWARDS',
   params: 
   { 
     player_id: 1,
     handcards: []
    }  
}


#GEWINNEN
{ 
  type: 'WIN', 
  params: 
  { 
    player: player.name 
  }
}

CURRENT_STATE

available values: lobby | ingame | intercept_phase | intercept_finished

lobby = spieler befinden sich in der lobby
ingame = spiel hat gestartet
intercept_phase = spieler hat ein monster ausgespielt/eine türkarte gezogen. Solange nicht alle spieler no_intercept drücken, ist das spiel in dieser phase.
intercept_finished = kein spieler wollte intercepten, zug ist "vorbei"
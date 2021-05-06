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
      helping_player: id | nil,
      intercept_timestamp: timestamp | nil,
      current_state: lobby | ingame | intercept_phase | intercept_finished
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



#ANFRAGE
{
  action: "curse_player",
  to: 1,
  unique_card_id: 4
  #to ist die id des anderen Players, der verflucht wird
}

#ANTWORT
{
  #GAMEBOARD WIE IMMER
}

#ANFRAGE
{
  action: "level_up",
  params: {
    unique_card_id: 4
  }
  #sollte man nur auf sich selbst spielenn können
}

#ANTWORT
{
  #GAMEBOARD WIE IMMER
}


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
    player: player.id 
    monster_won: id
  }
}

CURRENT_STATE

available values: lobby | ingame | intercept_phase | intercept_finished | boss_phase | boss_phase_finished | game_won

lobby = spieler befinden sich in der lobby
ingame = spiel hat gestartet
intercept_phase = spieler hat ein monster ausgespielt/eine türkarte gezogen. Solange nicht alle spieler no_intercept drücken, ist das spiel in dieser phase.
intercept_finished = kein spieler wollte intercepten, zug ist "vorbei"
boss_phase = spieler hat ein bossmonster aus dem Türstapel gezogen, alle spieler bekämpfen dieses monster gemeinsam
boss_phase_finished = kein spieler kann mehr etwas einwerfen, zug ist "vorbei"
game_won = ein spieler hat lvl 5 erreicht



DEV ACTIONS:

Alle im Game-Chanel

{
   type: 'develop_add_buff_card',
   params: { }  
}

{
   type: 'develop_add_curse_card',
   params: { }  
}

{
   type: 'develop_add_card_with_id',
   params: 
   { 
     # CARD ID not unique_card_id so you can add every card from our db to your hand
     card_id: 1
   }  
}

#rebroadcasts handcard update
{
   type: 'develop_broadcast_handcard_update',
   params: { }  
}

#rebroadcasts board update
{
   type: 'develop_broadcast_gameboard_update',
   params: { }  
}

{
   type: 'develop_set_myself_as_current_player',
   params: { }  
}

#set all players intercept to false
{
   type: 'develop_set_intercept_false',
   params: { }  
}

{
   type: 'develop_set_myself_as_winner',
   params: { }  
}

{
   type: 'develop_set_next_player_as_current_player',
   params: { }  
}


{
   type: 'develop_draw_boss_card',
   params: { }  
}

# FRIENDLISTCHANNEL

#on subscribe to channel kriegst du

{
  type: 'FRIENDLIST',
  params: {
    friends: [ {name: '', status: ''}]
  }
}

#wenn man ausstehende Freundschaftsanfragen hat
{
  type: 'FRIEND_REQUEST',
  params: { inquirer: id, inquirer_name: string }
}

#send request
{
  action: "send_friend_request",
  params:{
    friend: user_id #vom Spieler den man anfragen will
    }
}
#Antwort
{
  type: 'FRIEND_LOG', params: { message: string }
}
#Antwort beim angefragten spieler
{
  type: 'FRIEND_LOG', params: { message: string }
}
{
   type: 'FRIEND_REQUEST', params: { inquirer: id, inquirer_name: string }
}

#accept request
{
  action: "accept_friend_request",
  params:{
    inquirer: user_id #vom Spieler den man anfragen will
    }
}
#Antwort
{
  type: 'FRIEND_LOG', params: { message: string }
}
#Antwort beim anfragenden spieler
{
  type: 'FRIEND_LOG', params: { message: string }
}

#decline request
{
  action: "decline_friend_request",
  params:{
    inquirer: user_id #vom Spieler den man anfragen will
    }
}
#Antwort
{
  type: 'FRIEND_LOG', params: { message: string }
}

# LOBBYCHANNEL

#subscribe to lobby channel
{
  params:{
      #inquirer schickt man mit wenn ma a anfrage griag hat
      inquirer: user_id #vom Spieler den man anfragen will
      #initiate ist true wenn ma a neues spiel anfängt und nid eingladen wird
      initiate: boolean
    }
}

#invite to lobby
{
  action: "lobby_invite",
  params:{
      friend: user_id #vom Spieler den man anfragen will
    }
}
#Antwort im Friendlistchannel
{
  type: 'GAME_INVITE', params: { 
    inviter: id, 
    inviter_name: string 
    }
}

#select monster
{
  action: "add_monster",
  params:{
      monster_id: id von karte
    }
}

#remove monster from select
{
  action: "remove_monster",
  params:{
      monster_id: id von karte
    }
}

#remove monster from select
{
  action: "start_lobby_queue",
}

#Antwort wenn gameboard voll
#lobby_channel
ANTWORT
{
  type: 'START_GAME',
  params: {
    game_id: integer
  }
}
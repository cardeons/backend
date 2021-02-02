
class GamemethodsController < ApplicationController
    def draw_doorcard
        cursecards = Cursecard.all
        monstercards = Monstercard.all
        bosscards = Bosscard.all

        allcards = []

        for card in cursecards do
            x = card.draw_chance
            while x > 0
                allcards.push card
                x -=1
            end
        end

        for card in monstercards do
            x = card.draw_chance
            while x > 0
                allcards.push card
                x -=1
            end
        end

        for card in bosscards do
            x = card.draw_chance
            while x > 0
                allcards.push card
                x -=1
            end
        end

        randomcard = allcards[rand(allcards.length)]

        render json: { card: randomcard }, status: 200
    end

    def draw_treasurecard
        cursecards = Cursecard.all
        monstercards = Monstercard.all
        buffcards = Buffcard.all
        itemcards = Itemcard.all
        levelcards = Levelcard.all

        allcards = []

        for card in cursecards do
            x = card.draw_chance
            while x > 0
                allcards.push card
                x -=1
            end
        end

        for card in monstercards do
            x = card.draw_chance
            while x > 0
                allcards.push card
                x -=1
            end
        end

        for card in buffcards do
            x = card.draw_chance
            while x > 0
                allcards.push card
                x -=1
            end
        end

        for card in itemcards do
            x = card.draw_chance
            while x > 0
                allcards.push card
                x -=1
            end
        end

        for card in levelcards do
            x = card.draw_chance
            while x > 0
                allcards.push card
                x -=1
            end
        end

        randomcard = allcards[rand(allcards.length)]

        render json: { card: randomcard }, status: 200
    end

    def draw_handcards
        cursecards = Cursecard.all
        monstercards = Monstercard.all
        buffcards = Buffcard.all
        itemcards = Itemcard.all
        levelcards = Levelcard.all

        allcards = []

        for card in cursecards do
            x = card.draw_chance
            while x > 0
                allcards.push card.id
                x -=1
            end
        end

        for card in monstercards do
            x = card.draw_chance
            while x > 0
                allcards.push card.id
                x -=1
            end
        end

        for card in buffcards do
            x = card.draw_chance
            while x > 0
                allcards.push card.id
                x -=1
            end
        end

        for card in itemcards do
            x = card.draw_chance
            while x > 0
                allcards.push card.id
                x -=1
            end
        end

        for card in levelcards do
            x = card.draw_chance
            while x > 0
                allcards.push card.id
                x -=1
            end
        end

        handcard = Player.find(params[:id]).handcard

        Ingamedeck.where(cardable_type: 'Handcard', cardable_id: handcard.id).delete_all

        Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
        Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
        Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
        Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
        Ingamedeck.create(gameboard_id: params[:gameboard_id], card_id: allcards[rand(allcards.length)], cardable_id: handcard.id, cardable_type: 'Handcard')
        
        render json: { card: handcard.cards }, status: 200
    end
end
require 'rails_helper'

RSpec.describe Friendship, type: :model do
  fixtures :users

  it 'user should have 1 friend' do
    # gameboard = gameboards(:gameboardFourPlayers)
    users(:userOne).friends << users(:userTwo)

    expect(users(:userOne).friends.count).to eq 1
    expect(users(:userOne).friendships.first.pending).to be_truthy
  end

  it 'user should have 1 friend' do
    # gameboard = gameboards(:gameboardFourPlayers)
    Friendship.add_friend(users(:userOne), users(:userTwo))

    expect(users(:userTwo).friends.count).to eq 1
    expect(users(:userOne).friends.count).to eq 1
  end

  it 'user should have 0 friend' do
    # gameboard = gameboards(:gameboardFourPlayers)
    Friendship.add_friend(users(:userOne), users(:userTwo))
    Friendship.remove_friend(users(:userOne), users(:userTwo))

    expect(users(:userTwo).friends.reload.count).to eq 0
    expect(users(:userOne).friends.reload.count).to eq 0
  end
end

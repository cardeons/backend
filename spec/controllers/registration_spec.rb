# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController < ActionController::TestCase do
  before do
    @controller = RegistrationsController.new
  end

  it 'register successfully' do
    json = { email: 'paul.bauer@gmail.com', name: 'xXSniperXx', password: 'blumen123', password_confirmation: 'blumen123' }.to_json
    request.env['RAW_POST_DATA'] = json
    post :create, body: json

    expect(User.find_by('name=?', 'xXSniperXx')).to be_truthy
  end

  it 'get card on register' do
    json = { email: 'paul.bauer@gmail.com', name: 'xXSniperXx', password: 'blumen123', password_confirmation: 'blumen123' }.to_json
    request.env['RAW_POST_DATA'] = json
    post :create, body: json

    expect(User.find_by('name=?', 'xXSniperXx').cards.length).to eql(1)
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationCable::Connection, type: :channel do
  fixtures :users

  it 'successfully connects with valid JWT' do
    connect '/cable', headers: { 'HTTP_SEC_WEBSOCKET_PROTOCOL' => JWT.encode({ user_id: 1 }, 's3cr3t') }
    expect(connection.current_user.id).to eq 1
  end

  it 'rejects connection without valid JWT' do
    expect { connect '/cable', headers: { 'HTTP_SEC_WEBSOCKET_PROTOCOL' => '1' } }.to have_rejected_connection
  end

  it 'rejects connection without JWT' do
    expect { connect '/cable' }.to have_rejected_connection
  end
end

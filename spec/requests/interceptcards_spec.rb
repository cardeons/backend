# frozen_string_literal: true

require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe '/interceptcards', type: :request do
  # Interceptcard. As you add validations to Interceptcard, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    skip('Add a hash of attributes valid for your model')
  end

  let(:invalid_attributes) do
    skip('Add a hash of attributes invalid for your model')
  end

  describe 'GET /index' do
    it 'renders a successful response' do
      Interceptcard.create! valid_attributes
      get interceptcards_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      interceptcard = Interceptcard.create! valid_attributes
      get interceptcard_url(interceptcard)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    it 'renders a successful response' do
      get new_interceptcard_url
      expect(response).to be_successful
    end
  end

  describe 'GET /edit' do
    it 'render a successful response' do
      interceptcard = Interceptcard.create! valid_attributes
      get edit_interceptcard_url(interceptcard)
      expect(response).to be_successful
    end
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new Interceptcard' do
        expect do
          post interceptcards_url, params: { interceptcard: valid_attributes }
        end.to change(Interceptcard, :count).by(1)
      end

      it 'redirects to the created interceptcard' do
        post interceptcards_url, params: { interceptcard: valid_attributes }
        expect(response).to redirect_to(interceptcard_url(Interceptcard.last))
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new Interceptcard' do
        expect do
          post interceptcards_url, params: { interceptcard: invalid_attributes }
        end.to change(Interceptcard, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post interceptcards_url, params: { interceptcard: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'PATCH /update' do
    context 'with valid parameters' do
      let(:new_attributes) do
        skip('Add a hash of attributes valid for your model')
      end

      it 'updates the requested interceptcard' do
        interceptcard = Interceptcard.create! valid_attributes
        patch interceptcard_url(interceptcard), params: { interceptcard: new_attributes }
        interceptcard.reload
        skip('Add assertions for updated state')
      end

      it 'redirects to the interceptcard' do
        interceptcard = Interceptcard.create! valid_attributes
        patch interceptcard_url(interceptcard), params: { interceptcard: new_attributes }
        interceptcard.reload
        expect(response).to redirect_to(interceptcard_url(interceptcard))
      end
    end

    context 'with invalid parameters' do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        interceptcard = Interceptcard.create! valid_attributes
        patch interceptcard_url(interceptcard), params: { interceptcard: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe 'DELETE /destroy' do
    it 'destroys the requested interceptcard' do
      interceptcard = Interceptcard.create! valid_attributes
      expect do
        delete interceptcard_url(interceptcard)
      end.to change(Interceptcard, :count).by(-1)
    end

    it 'redirects to the interceptcards list' do
      interceptcard = Interceptcard.create! valid_attributes
      delete interceptcard_url(interceptcard)
      expect(response).to redirect_to(interceptcards_url)
    end
  end
end

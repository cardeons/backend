require 'rails_helper'

RSpec.describe Levelcard, type: :model do

    subject { 
        described_class.new(
        title: "Levelcard",
        description: "This is a levelcard",
        image: "path to image",
        action: "action",
        level_amount: 2,
        type: "Levelcard"
        )
    }

    it "is valid with valid attributes" do
        expect(subject).to be_valid
    end

    it "is not valid without a title" do
        subject.title = nil
        expect(subject).to_not be_valid
    end

    it "is not valid without a description" do
        subject.description = nil
        expect(subject).to_not be_valid
    end

    it "is not valid without an action" do
        subject.action = nil
        expect(subject).to_not be_valid
    end

    it "is not valid without a level amount" do 
        subject.level_amount = nil
        expect(subject).to_not be_valid
    end
    
    it "is not valid without a type" do 
        subject.type = nil
        expect(subject).to_not be_valid
    end
end

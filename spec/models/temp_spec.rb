require_relative '../spec_helper'

describe User, :type => :model do

  describe "User" do
    before do
      @user = User.new(name: :temp)
    end

    subject { @user }

    it { should respond_to(:name) }

    it "should be true" do
      expect(true).to be true
    end

    it "should be false" do
      expect(false).to be false
    end


  end
end
require 'spec_helper'

describe Address do

  let!(:address) { create(:address) }
  subject { address }

  it { should be_valid }

  describe "associations" do
    it { should belong_to(:customer) }
    it { should have_many(:orders) }
    it { should have_db_index(:customer_id) }
  end

  describe "validators" do
    describe "presence of validations" do
      [:city, :country, :line_1, :phone_number, :postcode].each do |attr|
        it { should validate_presence_of(attr) }
      end
    end

    it { should allow_value('12345').for(:postcode) }
    it { should_not allow_value('1234').for(:postcode) }
    it { should_not allow_value('123456').for(:postcode) }
  end

  describe "instance methods" do
    it "returns address info in html" do
      info = "#{address.line_1}<br/>#{address.line_2}<br/>#{address.country}<br/>" +
        "#{address.city}<br/>#{address.postcode}<br/>#{address.phone_number}"
      expect(address.info_in_html).to eq(info)
    end
  end

  describe "can't be destroyed if it's the only user address" do
    let(:user) { create(:user, addresses: [address]) }
    before { address.customer = user }

    its(:destroy) { should be_false }
  end
end

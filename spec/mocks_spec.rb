require 'spec_helper'

describe 'testing mocks' do

  it "test mocks" do
    myclass = double
    model = instance_double("myclass")
    allow(model).to receive(:example) {"Text returned by double"}

    expect( model.example ).to eq("Text returned by double")
  end

end


class Account
  attr_accessor :logger

  def close
    logger.account_closed(self)
  end
end

RSpec.describe Account do
  context "when closed" do
    it "logs an 'account closed' message" do
      logger = double()
      account = Account.new
      account.logger = logger

      expect(logger).to receive(:account_closed).with(account)

      account.close
    end
  end
end

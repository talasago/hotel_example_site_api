require 'rails_helper'

RSpec.describe Reserve, type: :model do
  it { is_expected.to validate_presence_of :plan_id }
  it { is_expected.to validate_presence_of :total_bill }
  it { is_expected.to validate_presence_of :date }
  it { is_expected.to validate_presence_of :term }
  it { is_expected.to validate_presence_of :head_count }
  it { is_expected.to validate_presence_of :username }
  it { is_expected.to validate_presence_of :contact }

  context 'contact is email' do
    subject { Reserve.new(contact: 'email') }
    it { is_expected.to validate_presence_of :email }
  end

  context 'contact is tel' do
    subject { Reserve.new(contact: 'tel') }
    it { is_expected.to validate_presence_of :tel }
  end
end
